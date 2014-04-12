using System;
using Irf.It.Thilo.DevtSim;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace DevtSimTests
{
    /// <summary>
    ///This is a test class for SimCoreTest and is intended
    ///to contain all SimCoreTest Unit Tests
    ///</summary>
    [TestClass()]
    public class SimCoreTest
    {
        private TestContext testContextInstance;

        /// <summary>
        ///Gets or sets the test context which provides
        ///information about and functionality for the current test run.
        ///</summary>
        public TestContext TestContext
        {
            get
            {
                return testContextInstance;
            }
            set
            {
                testContextInstance = value;
            }
        }

        #region Additional test attributes

        //
        //You can use the following additional attributes as you write your tests:
        //
        //Use ClassInitialize to run code before running the first test in the class
        //[ClassInitialize()]
        //public static void MyClassInitialize(TestContext testContext)
        //{
        //}
        //
        //Use ClassCleanup to run code after all tests in a class have run
        //[ClassCleanup()]
        //public static void MyClassCleanup()
        //{
        //}
        //
        //Use TestInitialize to run code before running each test
        //[TestInitialize()]
        //public void MyTestInitialize()
        //{
        //}
        //
        //Use TestCleanup to run code after each test has run
        //[TestCleanup()]
        //public void MyTestCleanup()
        //{
        //}
        //

        #endregion Additional test attributes

        /// <summary>
        ///A test for ScheduleEvent
        ///</summary>
        [TestMethod()]
        public void ScheduleEventTest()
        {
            SimCore_Accessor target = new SimCore_Accessor(); // TODO: Initialize to an appropriate value
            Event _event = new Event("test", 1.2d); // TODO: Initialize to an appropriate value
            target.ScheduleEvent(_event);
            var _exist = target.FutureEventList.Exists((e) =>
            {
                var _evt = (Event)e;
                if (_evt.UUID == _event.UUID) return true;
                return false;
            });
            Assert.IsTrue(_exist);
        }

        /// <summary>
        ///A test for RemoveEvent
        ///</summary>
        [TestMethod()]
        public void RemoveEventTest()
        {
            SimCore_Accessor target = new SimCore_Accessor(); // TODO: Initialize to an appropriate value
            Event _event = new Event("test", 1.2d); // TODO: Initialize to an appropriate value
            target.ScheduleEvent(_event);
            var _exist = target.FutureEventList.Exists((e) =>
            {
                var _evt = (Event)e;
                if (_evt.UUID == _event.UUID) return true;
                return false;
            });
            Assert.IsTrue(_exist);

            target.RemoveEvent(_event);
            _exist = target.FutureEventList.Exists((e) =>
            {
                var _evt = (Event)e;
                if (_evt.UUID == _event.UUID) return true;
                return false;
            });
            Assert.IsFalse(_exist);
        }

        /// <summary>
        /// A test for Run
        /// </summary>
        /// <param name="_numIt"></param>
        [TestMethod()]
        public void RunTest()
        {
            const int RUNS = 10;
            int _numIt = RUNS;
            var _rnd = new Random();
            int _exec = 0;
            SimCore target = SimCore_Accessor.Instance; // TODO: Initialize to an appropriate value
            for (int i = 0; i < _numIt; i++)
            {
                Event _event = new Event("test", _rnd.NextDouble() * 1000d); // TODO: Initialize to an appropriate value
                _event.OnEventExecutionPreEdges += (o, e) =>
                {
                    _exec++;
                };
                //target.ScheduleEvent(_event);
                _event.Schedule();
            }

            // Test edges
            int _numEvtFrom = RUNS;
            int _numEvtTo = RUNS;

            Event _eventTo = new Event("testWithEdge"); // TODO: Initialize to an appropriate value
            Event _eventFrom = new Event("testWithEdge", _rnd.NextDouble() * 1000d); // TODO: Initialize to an appropriate value
            Edge _edge = new Edge(_eventFrom, _eventTo);
            _edge.Distribution = new GenerateExponential();
            _eventFrom.OnEventExecutionPostEdges += (o, e) =>
            {
                _numEvtFrom++;
            };

            _eventTo.OnEventExecutionPostEdges += (o, e) =>
                {
                    _numEvtTo++;
                };
            //target.ScheduleEvent(_eventFrom);
            _eventFrom.Schedule();

            target.Run();
            Assert.IsTrue(_exec == _numIt);
            Assert.IsTrue(_numEvtFrom == _numEvtTo);

            // Test self edges
            int _numSelf = 0;

            Event _eventFromTo = new Event("testWithEdge", 0); // TODO: Initialize to an appropriate value

            Edge _edgeSelf = new Edge(_eventFromTo, _eventFromTo);
            _edge.Distribution = new GenerateNormal(20, 0.1);
            _eventFromTo.OnEventExecutionPreEdges += (o, e) =>
            {
                _numSelf++;
                if (_numSelf > RUNS)
                {
                    ((Event)o).Edges.Clear();
                }
            };
            //target.ScheduleEvent(_eventFromTo);
            _eventFromTo.Schedule();
            target.Run();
            Assert.IsTrue(_numSelf == RUNS + 1);
        }
    }
}