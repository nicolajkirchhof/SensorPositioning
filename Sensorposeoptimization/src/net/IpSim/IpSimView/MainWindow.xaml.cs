using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.ComponentModel;
using System.Linq;
using System.Text;
using System.Timers;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Media.Media3D;
using System.Windows.Navigation;
using System.Windows.Shapes;
using Irf.It.Thilo.IpSim;
using NExtensions;
using Xceed.Wpf.Toolkit.PropertyGrid;
using ht = HelixToolkit.Wpf;

namespace Irf.It.Thilo.Ipsim.View
{
    /// <summary>
    /// Interaction logic for MainWindow.xaml
    /// </summary>
    public partial class MainWindow : Window//, INotifyPropertyChanged
    {
        private Dictionary<string, IpObjectContainer> dictObjects = new Dictionary<string, IpObjectContainer>();

        public static ht.HelixViewport3D View { get; private set; }

        public MainWindow()
        {
            InitializeComponent();
            this.DataContext = this; //.animatedPoint;
            MainWindow.View = viewSimulation;
        }

        private void buttonAddSensor_Click(object sender, RoutedEventArgs e)
        {
            var _name = string.Format("Sensor{0}", dictObjects.Count);
            var _sensor = new SensorVisual3D(_name);
            this.viewSimulation.Children.Add(_sensor);
            dictObjects[_name] = new IpObjectContainer(_sensor);
            this.sensorTree.Items.Add(dictObjects[_name]);
            //this.viewSimulation.Children.Add(dictSensors[_name].Container);
        }

        private void buttonAddWall_Click(object sender, RoutedEventArgs e)
        {
            var _name = string.Format("Wall{0}", dictObjects.Count);
            var _sensor = new WallVisual3D(_name);
            this.viewSimulation.Children.Add(_sensor);
            dictObjects[_name] = new IpObjectContainer(_sensor);
            this.wallsTree.Items.Add(dictObjects[_name]);
        }

        private void CompositionTarget_Rendering(object sender, EventArgs e)
        {
        }

        private void contentTree_SelectedItemChanged(object sender, RoutedPropertyChangedEventArgs<object> e)
        {
            var _tree = sender as TreeView;
        }

        private void proptertyGrid_GotFocus(object sender, RoutedEventArgs e)
        {
            ((PropertyGrid)sender).Update();
        }

        private void testing_Click(object sender, RoutedEventArgs e)
        {
            var _btn = (Button)sender;
            var _sel = (IpObjectContainer)this.contentTree.SelectedItem;
            if (_sel.IsManipulatorEnabled)
            {
                _btn.Content = "Show";
                _btn.Background = new SolidColorBrush(Colors.Red);
            }
            else
            {
                _btn.Content = "Hide";
                _btn.Background = new SolidColorBrush(Colors.Green);
            }

            //foreach (KeyValuePair<string, IpObjectContainer> _item in this.dictObjects)
            //{
            //    _item.Value.IsManipulatorEnabled = !_item.Value.IsManipulatorEnabled;
            //}
        }

        private void buttonAddLocPoint_Click(object sender, RoutedEventArgs e)
        {
            var _name = string.Format("Point{0}", dictObjects.Count);
            var _sensor = new PointVisual3D(_name);
            this.viewSimulation.Children.Add(_sensor);
            dictObjects[_name] = new IpObjectContainer(_sensor);
            this.objectsTree.Items.Add(dictObjects[_name]);
        }
    }
}