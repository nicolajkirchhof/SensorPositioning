// -----------------------------------------------------------------------
// <copyright file="WallVisual3D.cs" company="TU-Dortmund">
// TODO: Update copyright text.
// </copyright>
// -----------------------------------------------------------------------

namespace Irf.It.Thilo.Ipsim.View
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Text;
    using System.Windows.Media;
    using System.Windows.Media.Media3D;
    using Irf.It.Thilo.IpSim;
    using ht = HelixToolkit.Wpf;

    /// <summary>
    /// TODO: Update summary.
    /// </summary>
    public class WallVisual3D : IpObjectVisual3D
    {
        public WallVisual3D()
            : base(new Wall(string.Empty))
        {
        }

        public WallVisual3D(string _name)
            : base(new Wall(_name))
        {
        }

        public WallVisual3D(Wall wall)
            : base(wall)
        {
        }

        private static readonly Material outsideMat = ht.MaterialHelper.CreateMaterial(Colors.Black, 0.5);

        private static readonly Material insideMat = ht.MaterialHelper.CreateMaterial(Colors.Green, 0.6);
        //private ht.TranslateManipulator translateModificator;

        /// <summary>
        /// The tessellate.
        /// </summary>
        /// <returns>The mesh.</returns>
        protected override MeshGeometry3D Tessellate()
        {
            var builder = new ht.MeshBuilder(true, true);
            var _bo = (IpObject)this;
            if (_bo != null)
            {
                builder.AddBox(_bo.Position, _bo.Size.X, _bo.Size.Y, _bo.Size.Z);
            }
            this.Material = outsideMat;
            this.BackMaterial = insideMat;
            return builder.ToMesh();
        }
    }
}