using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Text;
using System.Windows;
using System.Windows.Data;
using System.Windows.Media.Media3D;
using Irf.It.Thilo.IpSim;
using NExtensions;
using Xceed.Wpf.Toolkit.PropertyGrid;
using ht = HelixToolkit.Wpf;

namespace Irf.It.Thilo.Ipsim.View
{
    public abstract class IpObjectVisual3D : ht.MeshElement3D
    {
        public IpObjectVisual3D(IpObject baseObject)
        {
            this.BaseObject = baseObject;
        }

        private IpObject baseObject;

        public IpObject BaseObject
        {
            get { return this.baseObject; }
            protected set
            {
                this.baseObject = value;

                BindingOperations.SetBinding(this, PositionProperty, new Binding("Position")
                {
                    Source = this.BaseObject,
                    Mode = BindingMode.TwoWay,
                });

                BindingOperations.SetBinding(this, OrientationProperty, new Binding("Orientation")
                {
                    Source = this.BaseObject,
                    Mode = BindingMode.TwoWay,
                });
                this.baseObject.PropertyChanged += (object s, PropertyChangedEventArgs e) =>
                {
                    this.UpdateModel();
                };
            }
        }

        //public double Position
        //{
        //    get { return (double)GetValue(PositionProperty); }
        //    set { SetValue(PositionProperty, value); }
        //}

        // Using a DependencyProperty as the backing store for Position.  This enables animation, styling, binding, etc...
        private static void PositionChanged(DependencyObject d, DependencyPropertyChangedEventArgs e)
        {
            var obj = ((IpObjectVisual3D)d);
            var p0 = (Point3D)e.NewValue;
            obj.Transform = new TranslateTransform3D((Vector3D)p0);
            obj.UpdateModel();
        }

        public static readonly DependencyProperty PositionProperty =
            DependencyProperty.Register("Position", typeof(Point3D), typeof(IpObjectVisual3D), new PropertyMetadata(new Point3D(1, 0, 0), PositionChanged));

        public Point3D Position
        {
            get
            {
                return (Point3D)this.Transform.Value.GetTranslation();
            }
            set
            {
                SetValue(PositionProperty, value);
            }
        }

        // Using a DependencyProperty as the backing store for Orientation.  This enables animation, styling, binding, etc...
        private static void OrientationChanged(DependencyObject d, DependencyPropertyChangedEventArgs e)
        {
            var obj = ((IpObjectVisual3D)d);
            var value = (AxisAngle3D)e.NewValue;
            obj.Transform = new RotateTransform3D(new AxisAngleRotation3D(value.Axis, value.Angle + DOUBLE_Epsilon));
            obj.UpdateModel();
        }

        public static readonly DependencyProperty OrientationProperty =
            DependencyProperty.Register("Orientation", typeof(AxisAngle3D), typeof(IpObjectVisual3D), new PropertyMetadata(new AxisAngle3D(), OrientationChanged));

        private const double DOUBLE_Epsilon = 1e-6;

        public AxisAngle3D Orientation
        {
            get
            {
                return this.Transform.Value.ToAxisAngle3D();
            }
            set
            {
                // with angle of 0deg always the identity matrix is returned
                //this.Transform = new RotateTransform3D(new AxisAngleRotation3D(value.Axis, value.Angle + DOUBLE_Epsilon));
                //this.OnGeometryChanged();
                SetValue(OrientationProperty, value);
            }
        }

        //// Using a DependencyProperty as the backing store for Direction.  This enables animation, styling, binding, etc...
        //public static readonly DependencyProperty DirectionProperty =
        //    DependencyProperty.Register("Direction", typeof(Vector3D), typeof(SensorVisual3D), new PropertyMetadata(new Vector3D(1, 0, 0), GeometryChanged));

        //public string Name
        //{
        //    get { return (string)GetValue(NameProperty); }
        //    set { SetValue(NameProperty, value); }
        //}

        //// Using a DependencyProperty as the backing store for Name.  This enables animation, styling, binding, etc...
        //public static readonly DependencyProperty NameProperty =
        //    DependencyProperty.Register("Name", typeof(Size3D), typeof(SensorVisual3D), new PropertyMetadata(new Size3D(), GeometryChanged));

        //public Size3D Size
        //{
        //    get { return (Size3D)GetValue(SizeProperty); }
        //    set { SetValue(SizeProperty, value); }
        //}

        //// Using a DependencyProperty as the backing store for Size.  This enables animation, styling, binding, etc...
        //public static readonly DependencyProperty SizeProperty =
        //    DependencyProperty.Register("Size", typeof(Size3D), typeof(SensorVisual3D), new PropertyMetadata(new Size3D(0, 0, 0), GeometryChanged));

        /// <summary>
        /// The tessellate.
        /// </summary>
        /// <returns>The mesh.</returns>
        protected override MeshGeometry3D Tessellate()
        {
            var builder = new ht.MeshBuilder(true, true);
            builder.AddArrow(this.Position, this.Position + this.Orientation.Axis, 1);

            return builder.ToMesh();
        }

        // Event object
        public event EventHandler OnChanged;

        // Event raiser
        protected virtual void RaiseChanged(EventArgs e)
        {
            var handler = this.OnChanged;
            if (handler != null)
            {
                handler(this, e);
            }
        }

        public static explicit operator IpObject(IpObjectVisual3D obj)
        {
            return obj.BaseObject;
        }
    }
}