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

    public struct IpSensorDetection
    {
        public IpSensorDetection(LocateableObject _seenObject, Spherical3D _sensorObjectSperical)
            : this()
        {
            this.SeenObject = _seenObject;
            this.SenosorObjectVector = _sensorObjectSperical;
        }

        public LocateableObject SeenObject { get; set; }

        public Spherical3D SenosorObjectVector { get; set; }
    }
}