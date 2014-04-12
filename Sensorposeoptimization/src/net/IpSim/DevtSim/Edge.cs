using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

// -----------------------------------------------------------------------
// <copyright file="$safeitemrootname$.cs" company="$registeredorganization$">
// </copyright>
// -----------------------------------------------------------------------
namespace Irf.It.Thilo.DevtSim
{
    public class Edge
    {
        /// <summary>
        /// The source event
        /// </summary>
        public Event From
        {
            get;
            private set;
        }

        /// <summary>
        /// The target event
        /// </summary>
        public Event To
        {
            get;
            private set;
        }

        public Edge(Event _from, Event _to)
            : this(_from, _to, null)
        {
        }

        public Edge(Event _from, Event _to, RandomGenerate _distribution)
        {
            this.From = _from;
            this.To = _to;
            this.Distribution = _distribution;
            _from.Edges.Add(this);
        }

        /// <summary>
        /// Random distribution that is used to delay target event execution
        /// </summary>
        public RandomGenerate Distribution
        {
            get;
            set;
        }

        public void Activate()
        {
            var _sim = SimCore.Instance;
            //var _to = new Event(this.To);
            if (this.Distribution != null)
            {
                this.To.ExecutionTime = this.From.ExecutionTime + Math.Abs(this.Distribution.ComputeValue());
            }
            this.To.Schedule();
            //_sim.ScheduleEvent(this.To);
        }
    }
}