namespace Irf.It.Thilo.IpSim
{
    using System;
    using System.Windows.Media.Media3D;
    using NExtensions;

    public interface IIpObject
    {
        AxisAngle3D Orientation { get; set; }

        string Name { get; set; }

        Point3D Position { get; set; }

        Size3D Size { get; set; }
    }
}