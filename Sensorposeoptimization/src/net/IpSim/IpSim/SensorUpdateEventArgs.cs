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

    public class SensorUpdateEventArgs : EventArgs
    {
        public SensorUpdateEventArgs()
        {
            this.Detections = new List<IpSensorDetection>();
        }

        public List<IpSensorDetection> Detections { get; set; }
    }
}