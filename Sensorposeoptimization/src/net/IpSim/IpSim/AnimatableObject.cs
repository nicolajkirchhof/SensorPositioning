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
    using C5;
    using Irf.It.Thilo.DevtSim;
    using NExtensions;

    public class AnimatableObject : IpObject
    {
        private void sim_OnSensorUpdate(object sender, PreSensorUpdateEventArgs e)
        {
            var _nextKeyframe = Timeline.WeakSuccessor(new AnimatedKeyframe() { Time = e.Time });
            var _previousKeyframe = Timeline.WeakPredecessor(new AnimatedKeyframe() { Time = e.Time });
            this.ObjectState = _previousKeyframe.Interpolate(_nextKeyframe, e.Time);
        }

        public AnimatableObject(string _name)
            : base(_name)
        {
            this.Timeline = new TreeSet<AnimatedKeyframe>();
            sim.PreSensorUpdate += new EventHandler<PreSensorUpdateEventArgs>(sim_OnSensorUpdate);
        }

        private IpSimCore sim = IpSimCore.Instance;
        //private Point3D position;

        //public override Point3D Position
        //{
        //    get
        //    {
        //        return this.objectState.Position;
        //    }
        //    set
        //    {
        //        this.objectState.Position = value;
        //        this.RaisePropertyChanged(() => this.Position);
        //    }
        //}

        //private Vector3D direction;

        //public override Vector3D Direction
        //{
        //    get
        //    {
        //        return this.objectState.Direction;
        //    }
        //    set
        //    {
        //        this.objectState.Direction = value;
        //        this.RaisePropertyChanged(() => this.Direction);
        //    }
        //}

        private Keyframe objectState;

        public Keyframe ObjectState
        {
            get { return objectState; }
            set
            {
                objectState = value;
                this.RaisePropertyChanged(() => this.Position);
                this.RaisePropertyChanged(() => this.Orientation);
            }
        }

        public TreeSet<AnimatedKeyframe> Timeline { get; set; }
    }

    public class Keyframe : IComparable<Keyframe>
    {
        public double Time { get; set; }

        public Point3D Position { get; set; }

        public Vector3D Direction { get; set; }

        public int CompareTo(Keyframe other)
        {
            return this.Time.CompareTo(other.Time);
        }
    }

    public class AnimatedKeyframe : Keyframe
    {
        public delegate Keyframe Interpolation(Keyframe _from, Keyframe _to, double _percentage);

        public Interpolation InterpolationHandler { get; set; }

        public static Keyframe LinearKeyframeInterpolation(Keyframe _from, Keyframe _to, double _percentage)
        {
            var _newKey = new Keyframe();

            _newKey.Position = _from.Position.DotProduct((Point3D)(_to.Position - _from.Position).Multiply(_percentage));
            _newKey.Direction = _to.Direction.DotProduct((_to.Position - _from.Position).Multiply(_percentage));

            return _newKey;
        }

        public static Keyframe LinearStepInterpolation(Keyframe _from, Keyframe _to, double _percentage)
        {
            return new Keyframe()
            {
                Position = _from.Position,
                Direction = _from.Direction
            };
        }

        public Keyframe Interpolate(Keyframe _to, double _time)
        {
            var _percentage = (_time - this.Time) / (_to.Time - this.Time);
            return this.InterpolationHandler(this, _to, _percentage);
        }
    }
}