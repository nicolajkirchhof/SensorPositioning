using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using NExtensions;

// -----------------------------------------------------------------------
// <copyright file="$safeitemrootname$.cs" company="$registeredorganization$">
// </copyright>
// -----------------------------------------------------------------------
namespace Irf.It.Thilo.DevtSim
{
    public class EventExecutionEventArgs : EventArgs
    {
    }

    public class Event : IComparable<Event>
    {
        private static Random rnd = new Random();
        private static SimCore sim = SimCore.Instance;

        /// <summary>
        /// Is called whenever the event executes
        /// </summary>
        public event EventHandler<EventExecutionEventArgs> OnEventExecutionPostEdges;

        public event EventHandler<EventExecutionEventArgs> OnEventExecutionPreEdges;

        // Event raiser
        protected virtual void RaiseEventExecutionPastEdges(EventExecutionEventArgs e)
        {
            var handler = this.OnEventExecutionPostEdges;
            if (handler != null)
            {
                handler(this, e);
            }
        }

        // Event raiser
        protected virtual void RaiseEventExecutionPreEdges(EventExecutionEventArgs e)
        {
            var handler = this.OnEventExecutionPreEdges;
            if (handler != null)
            {
                handler(this, e);
            }
        }

        /// <summary>
        /// Short event name
        /// </summary>
        public string Name
        {
            get;
            set;
        }

        /// <summary>
        /// Optional description use if needed
        /// </summary>
        public string Description
        {
            get;
            set;
        }

        private double executionTime;

        /// <summary>
        /// Gets and sets the time when this event is executed
        /// </summary>
        public double ExecutionTime
        {
            get
            {
                return executionTime;
            }
            set
            {
                executionTime = value;
                if (this.IsScheduled)
                {
                    this.Cancel();
                    this.Schedule();
                }
            }
        }

        /// <summary>
        /// Gets or sets the events priority
        /// </summary>
        public int Priority
        {
            get;
            private set;
        }

        /// <summary>
        /// Gets or sets the unique identifier for this event
        /// </summary>
        public long UUID
        {
            get;
            private set;
        }

        public bool IsScheduled { get; private set; }

        /// <summary>
        /// List of edges which go from this event to another
        /// </summary>
        public List<Edge> Edges { get; set; }

        public Event(string _name, double _executionTime, int _priority, string _description)
        {
            this.Name = _name;
            this.ExecutionTime = _executionTime;
            this.Priority = _priority;
            this.Description = _description;
            this.UUID = rnd.NextLong();
            this.Edges = new List<Edge>();
        }

        public Event(string _name, double _executionTime, int _priority)
            : this(_name, _executionTime, _priority, String.Empty)
        {
        }

        public Event(string _name, double _executionTime)
            : this(_name, _executionTime, 0)
        {
        }

        public Event(string _name)
            : this(_name, double.NaN)
        {
        }

        public Event(Event p)
            : this(p.Name, p.ExecutionTime, p.Priority, p.Description)
        {
            if (p.Edges != null)
            {
                foreach (Edge _edge in this.Edges)
                {
                    this.Edges.Add(new Edge(this, new Event(_edge.To)));
                }
            }
            if (p.OnEventExecutionPreEdges != null)
            {
                this.OnEventExecutionPreEdges = p.OnEventExecutionPreEdges;
            }
            if (p.OnEventExecutionPostEdges != null)
            {
                this.OnEventExecutionPostEdges = p.OnEventExecutionPostEdges;
            }
        }

        public int CompareTo(Event other)
        {
            if (this.ExecutionTime == other.ExecutionTime)
            {
                if (this.Priority == other.Priority)
                {
                    return this.UUID == other.UUID ? 0 : -1;
                }
                return this.Priority > other.Priority ? 1 : -1;
            }
            return this.ExecutionTime > other.ExecutionTime ? 1 : -1;
        }

        public void Execute()
        {
            this.IsScheduled = false;
            this.RaiseEventExecutionPreEdges(new EventExecutionEventArgs());

            if (Edges.Count > 0)
            {
                foreach (Edge _edge in this.Edges)
                {
                    _edge.Activate();
                }
            }

            this.RaiseEventExecutionPastEdges(new EventExecutionEventArgs());
        }

        public Event Copy()
        {
            var _evt = new Event(this);
            return _evt;
        }

        /// <summary>
        /// Schedules the event for execution
        /// </summary>
        public void Schedule()
        {
            if (this.ExecutionTime == double.NaN)
            {
                throw new ArgumentOutOfRangeException("ExecutionTime is not set");
            }
            Event.sim.ScheduleEvent(this);
            this.IsScheduled = true;
        }

        /// <summary>
        /// Cancels the event execution
        /// </summary>
        public void Cancel()
        {
            if (this.IsScheduled)
            {
                throw new NotSupportedException("Event is not scheduled");
            }
            Event.sim.RemoveEvent(this);
            this.IsScheduled = false;
        }
    }
}