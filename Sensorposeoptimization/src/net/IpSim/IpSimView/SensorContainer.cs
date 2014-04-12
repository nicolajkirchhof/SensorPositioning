namespace Irf.It.Thilo.Ipsim.View
{
    using System.Windows;
    using System.Windows.Media.Media3D;
    using Irf.It.Thilo.IpSim;
    using ht = HelixToolkit.Wpf;

    public class IpObjectContainer : DependencyObject
    {
        // Using a DependencyProperty as the backing store for Name.  This enables animation, styling, binding, etc...
        public static readonly DependencyProperty NameProperty =
            DependencyProperty.Register("Name", typeof(string), typeof(IpObjectContainer));
        private bool isManipulatorEnabled = false;

        public IpObjectContainer(IpObjectVisual3D ipObjectVisual3D)
        {
            this.Name = ((IpObject)ipObjectVisual3D).Name;
            this.Container = new ContainerUIElement3D();
            this.Object = ipObjectVisual3D;
            this.Manipulator = new ht.CombinedManipulator();
            this.IsManipulatorEnabled = true;
        }

        public ContainerUIElement3D Container { get; private set; }

        public bool IsManipulatorEnabled
        {
            get
            {
                return isManipulatorEnabled;
            }
            set
            {
                if (this.isManipulatorEnabled == value)
                    return;

                if (value)
                {
                    MainWindow.View.Children.Add(this.Manipulator);
                    this.Manipulator.Bind(this.Object);
                }
                else
                {
                    MainWindow.View.Children.Remove(this.Manipulator);
                    this.Manipulator.UnBind();
                }
                isManipulatorEnabled = value;
            }
        }

        public ht.CombinedManipulator Manipulator { get; private set; }

        public string Name
        {
            get { return (string)GetValue(NameProperty); }
            set { SetValue(NameProperty, value); }
        }

        public IpObjectVisual3D Object { get; private set; }

        //public ht.HelixViewport3D View { get; private set; }
    }
}