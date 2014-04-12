// -----------------------------------------------------------------------
// <copyright file="$safeitemrootname$.cs" company="$registeredorganization$">
// </copyright>
// -----------------------------------------------------------------------
namespace Irf.It.Thilo.IpSim
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Text;
    using System.Windows.Media.Media3D;
    using Irf.It.Thilo.DevtSim;
    using NExtensions;
    using NExtensions.MathHelper;

    public abstract class IpSensor : IpObject, ISphericalRange3D
    {
        private SphericalRange3D fov = new SphericalRange3D();
        private double maxRange;
        private double minRange;
        private IpSimCore sim = IpSimCore.Instance;
        private double updateRate;

        public IpSensor(string _name)
            : base(_name)
        {
            this.SensorUpdateEvent = new Event(this.Name);
            this.SensorUpdateEvent.OnEventExecutionPostEdges += (o, e) =>
            {
                var _data = this.GenerateSensordata();
                this.RaiseSensorUpdate(_data);
            };

            this.SensorRescheduleEdge = new Edge(this.SensorUpdateEvent, this.SensorUpdateEvent);
            this.MaxRange = double.NaN;
            this.MinRange = double.NaN;
        }

        // Event object
        public event EventHandler<SensorUpdateEventArgs> OnSensorUpdate;

        public double AzimuthRange
        {
            get
            {
                return this.fov.AzimuthRange;
            }
            set
            {
                this.fov.AzimuthRange = value;
                this.RaisePropertyChanged(() => this.AzimuthRange);
            }
        }

        public Vector3D Direction
        {
            get
            {
                return fov.Direction;
            }
            set
            {
                this.fov.Direction = value;
                this.Orientation = new AxisAngle3D(value, this.Rotation);
                this.RaisePropertyChanged(() => this.Orientation);
            }
        }

        public override AxisAngle3D Orientation
        {
            get
            {
                return this.orientation;
            }
            set
            {
                this.orientation = value;
                this.fov.Direction = value.Axis;
                this.fov.Rotation = value.Angle;
                this.RaisePropertyChanged(() => this.Orientation);
            }
        }

        public double AzimuthRangeDegree
        {
            get
            {
                return this.fov.AzimuthRangeDegree;
            }
            set
            {
                this.fov.AzimuthRangeDegree = value;
                this.RaisePropertyChanged(() => this.AzimuthRangeDegree);
            }
        }

        public Spherical3D DirectionSpherical
        {
            get
            {
                return this.fov.DirectionSpherical;
            }
            set
            {
                this.fov.DirectionSpherical = value;
                this.RaisePropertyChanged(() => this.DirectionSpherical);
            }
        }

        public double ElevationRange
        {
            get
            {
                return this.fov.ElevationRange;
            }
            set
            {
                this.fov.ElevationRange = value;
                this.RaisePropertyChanged(() => this.ElevationRange);
            }
        }

        public double ElevationRangeDegree
        {
            get
            {
                return this.fov.ElevationRangeDegree;
            }
            set
            {
                this.fov.ElevationRangeDegree = value;
                this.RaisePropertyChanged(() => this.ElevationRangeDegree);
            }
        }

        public SphericalRange3D Fov
        {
            get
            {
                return fov;
            }
            set
            {
                fov = value;
                this.RaisePropertyChanged(() => this.Fov);
            }
        }

        public bool IsActive { get { return this.SensorUpdateEvent.IsScheduled; } }

        public double MaxRange
        {
            get
            {
                return maxRange;
            }
            set
            {
                maxRange = value;
                this.RaisePropertyChanged(() => this.MaxRange);
            }
        }

        public double MinRange
        {
            get
            {
                return minRange;
            }
            set
            {
                minRange = value;
                this.RaisePropertyChanged(() => this.MinRange);
            }
        }

        public override Point3D Position
        {
            get
            {
                return fov.Position;
            }
            set
            {
                this.position = value;
                this.fov.Position = value;
                this.RaisePropertyChanged(() => this.Position);
            }
        }

        public double Rotation
        {
            get
            {
                return this.fov.Rotation;
            }
            set
            {
                this.fov.Rotation = value;
                this.Orientation = new AxisAngle3D(this.Direction, value);
                this.RaisePropertyChanged(() => this.Orientation);
            }
        }

        public Edge SensorRescheduleEdge { get; private set; }

        public Event SensorUpdateEvent { get; private set; }

        /// <summary>
        /// Sets and Gets the update rate in Hz
        /// </summary>
        public double UpdateRate
        {
            get
            {
                return updateRate;
            }
            set
            {
                this.updateRate = value;
                if (this.IsActive)
                {
                    this.SensorUpdateEvent.Cancel();
                }
                this.SensorUpdateEvent.ExecutionTime = sim.DevtSimulation.Now + (1 / this.UpdateRate);
                this.SensorRescheduleEdge.Distribution = new GenerateConstant(1 / this.UpdateRate);
                this.SensorUpdateEvent.OnEventExecutionPreEdges += (o, e) =>
                {
                    if (this.sim.IsSimulationFinished)
                    {
                        ((Event)o).Edges.Clear();
                    }
                };
                this.SensorUpdateEvent.Schedule();
            }
        }

        public bool IsInRange(Point3D observation, out Vector3D direction)
        {
            return this.fov.IsInRange(observation, out direction);
        }

        //public List<Edge> PastEdges { get; set; }
        //protected virtual SensorUpdateEventArgs GenerateSensordata();
        protected virtual SensorUpdateEventArgs GenerateSensordata()
        {
            var _suea = new SensorUpdateEventArgs();
            foreach (LocateableObject _object in IpSimCore.Instance.LocatableObjects)
            {
                Vector3D _dir;
                if (this.Fov.IsInRange(this.Position, out _dir))
                {
                    var _vec2Obj = _dir.ToSpherical();
                    var _det = new IpSensorDetection(_object, _vec2Obj);
                    _suea.Detections.Add(_det);
                }
            }
            return _suea;
        }

        //public List<Edge> ActiveEdges { get; set; }
        // Event raiser
        protected virtual void RaiseSensorUpdate(SensorUpdateEventArgs e)
        {
            var handler = this.OnSensorUpdate;
            if (handler != null)
            {
                handler(this, e);
            }
        }

        //public List<Event> ScheduledEvents { get; private set; }

        //public List<Event> PastEvents { get; private set; }
    }
}