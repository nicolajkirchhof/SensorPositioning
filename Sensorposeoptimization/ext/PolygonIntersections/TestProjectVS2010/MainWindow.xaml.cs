using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;
using System.Drawing.Drawing2D;
using System.Drawing;

namespace GpcTest
{
	/// <summary>
	/// Interaktionslogik für MainWindow.xaml
	/// </summary>
	public partial class MainWindow : Window
	{
		System.Drawing.FontFamily fontFamily = new System.Drawing.FontFamily("Times New Roman");
		float flatness = 1.0F;

		public MainWindow()
		{
			InitializeComponent();
			panel.Paint += new System.Windows.Forms.PaintEventHandler(panel_Paint);
		}

		void panel_Paint(object sender, System.Windows.Forms.PaintEventArgs e)
		{
			GraphicsPath p = new GraphicsPath();

			// draw A
			p.AddString("A", fontFamily, 0, 250, new System.Drawing.Point(0, 0), new StringFormat());
			p.Flatten(new System.Drawing.Drawing2D.Matrix(), flatness);
			e.Graphics.FillPath(System.Drawing.Brushes.DarkGray, p);
			e.Graphics.DrawPath(new System.Drawing.Pen(System.Drawing.Color.Black, 2.0F), p);
			// draw B
			p.AddString("B", fontFamily, 0, 250, new System.Drawing.Point(0, 250), new StringFormat());
			p.Flatten(new System.Drawing.Drawing2D.Matrix(), flatness);
			e.Graphics.FillPath(System.Drawing.Brushes.DarkGray, p);
			e.Graphics.DrawPath(new System.Drawing.Pen(System.Drawing.Color.Black, 2.0F), p);

			// create polygonA
			p = new GraphicsPath();
			p.AddString("A", fontFamily, 0, 250, new System.Drawing.Point(0, 0), new StringFormat());
			p.Flatten(new System.Drawing.Drawing2D.Matrix(), flatness);
			GpcWrapper.Polygon polygonA = new GpcWrapper.Polygon(p);

			// create polygonB
			p = new GraphicsPath();
			p.AddString("B", fontFamily, 0, 250, new System.Drawing.Point(0, 0), new StringFormat());
			p.Flatten(new System.Drawing.Drawing2D.Matrix(), flatness);
			GpcWrapper.Polygon polygonB = new GpcWrapper.Polygon(p);

			// Save and Load
			//polygonA.Save("A.plg", true);
			//GpcWrapper.Polygon loadedPolygon = GpcWrapper.Polygon.FromFile("A.plg", true);

			// create Tristrip
			GpcWrapper.Tristrip tristrip = polygonA.ToTristrip();
			for (int i = 0; i < tristrip.NofStrips; i++)
			{
				GpcWrapper.VertexList vertexList = tristrip.Strip[i];
				GraphicsPath path = vertexList.TristripToGraphicsPath();
				System.Drawing.Drawing2D.Matrix m = new System.Drawing.Drawing2D.Matrix();
				m.Translate(600, 0);
				path.Transform(m);
				e.Graphics.FillPath(System.Drawing.Brushes.DarkGray, path);
				e.Graphics.DrawPath(Pens.Black, path);
			}

			PointF[] upperLeftCorner = new PointF[] { new PointF(200, 0), new PointF(200, 250), new PointF(400, 0), new PointF(400, 250) };

			int position = 0;
			foreach (GpcWrapper.GpcOperation operation in Enum.GetValues(typeof(GpcWrapper.GpcOperation)))
			{
				GpcWrapper.Polygon polygon = polygonA.Clip(operation, polygonB);
				GraphicsPath path = polygon.ToGraphicsPath();
				System.Drawing.Drawing2D.Matrix m = new System.Drawing.Drawing2D.Matrix();
				m.Translate(upperLeftCorner[position].X, upperLeftCorner[position].Y);
				path.Transform(m);
				e.Graphics.FillPath(System.Drawing.Brushes.DarkGray, path);
				e.Graphics.DrawPath(Pens.Black, path);
				position++;
			}

            GpcWrapper.Polygon p1 = new GpcWrapper.Polygon();

            double[] x = { 0.6596,  -2.3288,   -2.3288, -2.0418,   -2.7998,   -2.8296,   -2.8381,   -2.8381,   -1.2275};
            double[] y = {  9.2627,    2.7955,    2.7955,    3.4165,    3.1377,    3.1593,    3.1236,    3.1236,    9.9151, 0.9210,    0.1850,    1.3099};

            GpcWrapper.VertexList vl = new GpcWrapper.VertexList(x, y);
            p1.AddContour(vl, false);
            
           double[] x1 = { -3.1949,   -3.5350,   -3.2682};
            double[] y1 = {  0.9210,    0.1850,    1.3099};

            GpcWrapper.VertexList vl1 = new GpcWrapper.VertexList(x1, y1);
            p1.AddContour(vl1, false);

            GpcWrapper.Polygon p2 = new GpcWrapper.Polygon();

            GpcWrapper.VertexList vl2 = new GpcWrapper.VertexList(new double[] { -3.5600, -3.3829, -4.6015, -2.8381 }, new double[] { 2.8580, 1.9185, 2.4748, 3.1236 });
            p2.AddContour(vl2, false);

            GpcWrapper.VertexList vl3 = new GpcWrapper.VertexList(new double[] { -1.7619, - 2.8207, - 2.3672, - 2.5190, - 2.3288, - 2.7998, - 2.8223, - 2.8223, - 2.7998 }, new double[] { 2.3837,    1.7308,    2.0105,    2.3837,    2.7955,    3.1377,    3.1294 ,   3.1294,    3.1377 });
            p2.AddContour(vl3, false);

            var p3 = p1.Clip(GpcWrapper.GpcOperation.Difference, p2);
		}
	}
}
