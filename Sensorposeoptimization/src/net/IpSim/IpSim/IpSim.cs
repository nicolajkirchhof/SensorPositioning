using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Irf.It.Thilo.DevtSim;

// -----------------------------------------------------------------------
// <copyright file="$safeitemrootname$.cs" company="$registeredorganization$">
// </copyright>
// -----------------------------------------------------------------------
namespace Irf.It.Thilo.IpSim
{
    public class IpSimCore
    {
        public SimCore DevtSimulation { get; set; }

        public double SimulationLength { get; set; }

        public List<LocateableObject> LocatableObjects { get; set; }

        public List<IpSensor> Sensors { get; set; }

        public List<Wall> Walls { get; set; }

        public bool IsSimulationFinished
        {
            get { return DevtSimulation.Now >= this.SimulationLength; }
        }

        private void DevtSimulation_OnEventExecution(object sender, PreEventExecutionEventArgs e)
        {
            this.RaiseSensorUpdate(new PreSensorUpdateEventArgs() { Time = e.ExecutedEvent.ExecutionTime });
        }

        private IpSimCore()
        {
            this.DevtSimulation = SimCore.Instance;
            this.DevtSimulation.PreEventExecution += new EventHandler<PreEventExecutionEventArgs>(DevtSimulation_OnEventExecution);
            this.SimulationLength = double.PositiveInfinity;
            this.LocatableObjects = new List<LocateableObject>();
            this.Sensors = new List<IpSensor>();
            this.Walls = new List<Wall>();
        }

        private static IpSimCore instance;

        public static IpSimCore Instance
        {
            get
            {
                if (instance == null)
                {
                    instance = new IpSimCore();
                }
                return instance;
            }
        }

        // Event object
        public event EventHandler<PreSensorUpdateEventArgs> PreSensorUpdate;

        // Event raiser
        protected virtual void RaiseSensorUpdate(PreSensorUpdateEventArgs e)
        {
            var handler = this.PreSensorUpdate;
            if (handler != null)
            {
                handler(this, e);
            }
        }
    }

    public class PreSensorUpdateEventArgs : EventArgs
    {
        public double Time { get; set; }
    }
}