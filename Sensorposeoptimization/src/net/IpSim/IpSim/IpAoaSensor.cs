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
    using NExtensions;

    public class IpAoaSensor : IpSensor
    {
        public IpAoaSensor()
            : this(string.Empty)
        {
        }

        public IpAoaSensor(string _name)
            : base(_name)
        {
            this.Fov.MinRange = 0;
            this.Fov.MaxRange = double.MaxValue;
        }

        //protected override void RaiseSensorUpdate(SensorUpdateEventArgs e)
        //{
        //    //this.CalculateAoas();
        //    base.RaiseSensorUpdate(e);
        //}

        //protected override SensorUpdateEventArgs GenerateSensordata()
        //{
        //    var _suea = new SensorUpdateEventArgs();
        //    foreach (LocateableObject _object in IpSimCore.Instance.LocatableObjects)
        //    {
        //        Vector3D _dir;
        //        if (this.Fov.IsInRange(this.Position, out _dir))
        //        {
        //            var _vec2Obj = _dir.ToSpherical();
        //            var _det = new IpSensorDetection(_object, _vec2Obj);
        //            _suea.Detections.Add(_det);
        //        }
        //    }
        //    return _suea;
        //}
    }
}