// -----------------------------------------------------------------------
// <copyright file="$safeitemrootname$.cs" company="$registeredorganization$">
// </copyright>
// -----------------------------------------------------------------------
namespace Irf.It.Thilo.IpSim
{
    using System;
    using System.Collections.Generic;
    using System.Diagnostics;
    using System.Linq;
    using System.Text;
    using System.Windows.Media.Media3D;
    using C5;
    using Irf.It.Thilo.DevtSim;
    using NExtensions;

    [DebuggerDisplay("Time:{Time} ; Position:{Position} ; Orientation:{Orientation}")]
    public struct Pose3D : IComparable //: Observable
    {
        //protected AxisAngle3D orientation = new AxisAngle3D();
        //protected Point3D position = new Point3D();

        public AxisAngle3D Orientation
        {
            get;
            set;
        }

        public Point3D Position
        {
            get;
            set;
        }

        public double Time { get; set; }

        public static Pose3D Interpolate(Pose3D start, Pose3D end, double time)
        {
            var percentage = (time - start.Time) / (end.Time - start.Time);
            return new Pose3D()
            {
                Position = new Point3D()
                {
                    X = start.Position.X + percentage * (end.Position.X - start.Position.X),
                    Y = start.Position.Y + percentage * (end.Position.Y - start.Position.Y),
                    Z = start.Position.Z + percentage * (end.Position.Z - start.Position.Z)
                },
                Orientation = new AxisAngle3D()
                {
                    X = start.Orientation.X + percentage * (end.Orientation.X - start.Orientation.X),
                    Y = start.Orientation.Y + percentage * (end.Orientation.Y - start.Orientation.Y),
                    Z = start.Orientation.Z + percentage * (end.Orientation.Z - start.Orientation.Z),
                    W = start.Orientation.W + percentage * (end.Orientation.W - start.Orientation.W)
                },
                Time = time
            };
        }

        public int CompareTo(object obj)
        {
            return this.Time.CompareTo(((Pose3D)obj).Time);
        }
    }

    [DebuggerDisplay("Position:{Position} ; Orientation:{Orientation}")]
    public abstract class IpObject : Observable, IIpObject
    {
        public TreeSet<Pose3D> Keyframes { get; private set; }

        protected AxisAngle3D orientation = new AxisAngle3D();
        protected Point3D position = new Point3D();
        protected double rotation;
        protected Event scheduler = new Event(string.Empty);
        protected Size3D size;

        public Pose3D GetAnimatedPose(double time)
        {
            //var start = Keyframes.Last(kv => kv.Key <= time);
            //var end = Keyframes.First(kv => kv.Key >= time);
            var _finder = new Pose3D() { Time = time };
            var start = Keyframes.WeakPredecessor(_finder);
            var end = Keyframes.WeakSuccessor(_finder);
            if (start.CompareTo(end) == 0)
            {
                return start;
            }
            return Pose3D.Interpolate(start, end, time);
        }

        public void SetKeyframe(double time)
        {
            var _find = new Pose3D() { Time = time };
            if (this.Keyframes.Contains(_find))
            {
                this.Keyframes.Remove(_find);
            }

            this.Keyframes.Add(new Pose3D()
            {
                Orientation = this.Orientation,
                Position = this.Position,
                Time = time
            });
        }

        protected IpObject(string _name)
        {
            this.Name = _name;
            this.Keyframes = new TreeSet<Pose3D>();
        }

        public string Name
        {
            get
            {
                return this.scheduler.Name;
            }
            set
            {
                this.scheduler.Name = value;
                this.RaisePropertyChanged(() => this.Name);
            }
        }

        public virtual AxisAngle3D Orientation
        {
            get
            {
                return this.orientation;
            }
            set
            {
                this.orientation = value;
                this.RaisePropertyChanged(() => this.Orientation);
            }
        }

        public virtual Point3D Position
        {
            get
            {
                return this.position;
            }
            set
            {
                this.position = value;
                this.RaisePropertyChanged(() => this.Position);
            }
        }

        public Size3D Size
        {
            get
            {
                return size;
            }
            set
            {
                size = value;
                this.RaisePropertyChanged(() => this.Size);
            }
        }
    }
}