using System;
using System.Linq;
using System.Text;
using C5;
using SCG = System.Collections.Generic;

// -----------------------------------------------------------------------
// <copyright file="$safeitemrootname$.cs" company="$registeredorganization$">
// </copyright>
// -----------------------------------------------------------------------
namespace Irf.It.Thilo.DevtSim
{
    public sealed class SimCore
    {
        private IDictionary<long, IPriorityQueueHandle<Event>> eventHandles;

        private SimCore()
        {
            this.FutureEventList = new IntervalHeap<Event>();
            this.eventHandles = new HashDictionary<long, IPriorityQueueHandle<Event>>();
            this.IsRunning = false;
            this.Now = 0;
            this.Next = double.NaN;
            this.Last = double.NaN;
        }

        private static SimCore instance;

        public static SimCore Instance
        {
            get
            {
                if (instance == null)
                {
                    instance = new SimCore();
                }
                return instance;
            }
        }

        /// <summary>
        /// Current simulation time
        /// </summary>
        public double Now { get; private set; }

        /// <summary>
        /// Time for the next scheduled event
        /// </summary>
        public double Next { get; private set; }

        /// <summary>
        /// Time for the last occurred event
        /// </summary>
        public double Last { get; private set; }

        public IPriorityQueue<Event> FutureEventList
        {
            get;
            private set;
        }

        /// <summary>
        /// Adds an Event to the Event queue
        /// </summary>
        internal void ScheduleEvent(Event _event)
        {
            IPriorityQueueHandle<Event> _h = null;
            FutureEventList.Add(ref _h, _event);
            this.eventHandles.Add(_event.UUID, _h);
        }

        internal void RemoveEvent(Event _event)
        {
            IPriorityQueueHandle<Event> _h;
            this.eventHandles.Remove(_event.UUID, out _h);
            FutureEventList.Delete(_h);
        }

        internal void RescheduleEvent(Event _event)
        {
            this.RemoveEvent(_event);
            this.ScheduleEvent(_event);
        }

        // Event object
        public event EventHandler<PreEventExecutionEventArgs> PreEventExecution;

        // Event raiser
        private void RaiseEventExecution(PreEventExecutionEventArgs e)
        {
            var handler = this.PreEventExecution;
            if (handler != null)
            {
                handler(this, e);
            }
        }

        public void Run()
        {
            if (!this.IsRunning)
            {
                this.IsRunning = true;
                while (this.FutureEventList.Count > 0)
                {
                    var _event = this.FutureEventList.DeleteMin();
                    RaiseEventExecution(new PreEventExecutionEventArgs(_event));
                    this.eventHandles.Remove(_event.UUID);
                    if (this.FutureEventList.Count > 0)
                    {
                        this.Next = this.FutureEventList.FindMin().ExecutionTime;
                    }
                    else
                    {
                        this.Next = double.NaN;
                    }
                    this.Last = this.Now;
                    this.Now = _event.ExecutionTime;

                    _event.Execute();
                }
                this.IsRunning = false;
            }
        }

        public bool IsRunning { get; set; }
    }

    public class PreEventExecutionEventArgs : EventArgs
    {
        public Event ExecutedEvent { get; set; }

        public PreEventExecutionEventArgs(Event _executedEvent)
        {
            this.ExecutedEvent = _executedEvent;
        }

        public PreEventExecutionEventArgs()
        { }
    }
}