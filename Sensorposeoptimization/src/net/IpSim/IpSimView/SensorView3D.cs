// -----------------------------------------------------------------------
// <copyright file="SensorView3D.cs" company="TU-Dortmund">
// </copyright>
// -----------------------------------------------------------------------

namespace Irf.It.Thilo.Ipsim.View
{
    using System;
    using System.Collections.Generic;
    using System.Collections.ObjectModel;
    using System.Collections.Specialized;
    using System.ComponentModel;
    using System.Linq;
    using System.Text;
    using System.Windows;
    using System.Windows.Data;
    using System.Windows.Input;
    using System.Windows.Markup;
    using System.Windows.Media;
    using System.Windows.Media.Media3D;
    using Irf.It.Thilo.IpSim;
    using NExtensions;
    using ht = HelixToolkit.Wpf;

    public class SensorVisual3D : IpObjectVisual3D
    {
        private const double DBL_EqualOffset = 1e-6;

        #region Public Properties

        public IpSensor Sensor { get { return (IpSensor)this.BaseObject; } private set { this.BaseObject = value; } }

        #endregion Public Properties

        #region Methods

        public SensorVisual3D()
            : base(new IpAoaSensor(string.Empty))
        {
            this.Sensor = new IpAoaSensor(string.Empty)
            {
                Fov = new SphericalRange3D()
                {
                    AzimuthRange = 0.5,
                    ElevationRange = 0.5,
                    Direction = new Vector3D(1, 0, 0)
                },

                Position = new Point3D(0, 0, 0),
                MaxRange = 5,
            };
            this.Position = this.Sensor.Position;
            this.Sensor.PropertyChanged += (object s, PropertyChangedEventArgs e) =>
            {
                this.UpdateModel();
            };
        }

        public SensorVisual3D(string _name)
            : base(new IpAoaSensor(_name))
        {
            //this.Sensor = new IpAoaSensor(_name)
            //{
            this.Sensor.Fov = new SphericalRange3D()
            {
                AzimuthRange = 0.5,
                ElevationRange = 0.5,
                Direction = new Vector3D(1, 0, 0)
            };

            this.Position = this.Sensor.Position;
            //this.Fov = this.Sensor.Fov;
            this.Sensor.PropertyChanged += (object s, PropertyChangedEventArgs e) =>
            {
                this.UpdateModel();
            };
            //var rangeBinding = new Binding("MaxRange");
            //rangeBinding.Source = this.Sensor;
            //BindingOperations.SetBinding(this, SensorVisual3D.MaxRangeProperty, rangeBinding);
        }

        public SensorVisual3D(IpSensor _sensor)
            : base(_sensor)
        {
            //this.Sensor = _sensor;
            //this.Fov = _sensor.Fov;
            this.Sensor.PropertyChanged += (object s, PropertyChangedEventArgs e) =>
            {
                this.UpdateModel();
            };
            // todo: to be tested
            //var rangeBinding = new Binding("MaxRange");
            //rangeBinding.Source = this.Sensor;
            //BindingOperations.SetBinding(this, SensorVisual3D.MaxRangeProperty, rangeBinding);
        }

        private Material outsideMat = ht.MaterialHelper.CreateMaterial(Colors.Gold, 0.6);

        private Material insideMat = ht.MaterialHelper.CreateMaterial(Colors.Green, 0.6);
        //private ht.TranslateManipulator translateModificator;

        /// <summary>
        /// The tessellate.
        /// </summary>
        /// <returns>The mesh.</returns>
        protected override MeshGeometry3D Tessellate()
        {
            var builder = new ht.MeshBuilder(true, true);
            // Position and Rotation must not be concidered because they are handled by the visual 3d
            if (this.Sensor == null)
            {
                builder.AddPyramid(new Point3D(), 1, 1);
                return builder.ToMesh();
            }
            var _zeroPosition = new Point3D();// this.Transform.Value.GetTranslation() - this.Position;

            var _length = new Spherical3D(this.Sensor.MaxRange, 0, 0);

            var _dirSp = this.Orientation.Axis.ToSpherical();
            _dirSp.Radius = 0;

            var _p0AzOffset = new Spherical3D(0, 0, this.Sensor.AzimuthRange / 2.0);
            var _p0ElOffset = new Spherical3D(0, this.Sensor.ElevationRange / 2.0, 0);

            var _pts = new List<Point3D>();
            _pts.Add(_zeroPosition + this.Orientation.Axis + (_length + _p0ElOffset - _p0AzOffset + _dirSp).ToDirection());
            _pts.Add(_zeroPosition + this.Orientation.Axis + (_length + _p0ElOffset + _p0AzOffset + _dirSp).ToDirection());
            _pts.Add(_zeroPosition + this.Orientation.Axis + (_length - _p0ElOffset + _p0AzOffset + _dirSp).ToDirection());
            _pts.Add(_zeroPosition + this.Orientation.Axis + (_length - _p0ElOffset - _p0AzOffset + _dirSp).ToDirection());

            _pts.Sort((Point3D a, Point3D b) =>
            {
                if (Math.Abs(a.X - b.X) < DBL_EqualOffset)
                {
                    if (Math.Abs(a.Y - b.Y) < DBL_EqualOffset)
                    {
                        return a.Z.CompareTo(b.Z);
                    }
                    return a.Y.CompareTo(b.Y);
                }
                return a.X.CompareTo(b.X);
            });

            // outside
            builder.AddTriangle(_pts[0], _zeroPosition, _pts[1]);
            builder.AddTriangle(_pts[3], _zeroPosition, _pts[2]);
            builder.AddTriangle(_pts[2], _zeroPosition, _pts[0]);
            builder.AddTriangle(_pts[1], _zeroPosition, _pts[3]);

            this.Material = this.outsideMat;
            this.BackMaterial = this.insideMat;
            return builder.ToMesh();
        }

        #endregion Methods
    }
}