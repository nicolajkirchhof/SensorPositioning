using System;
using System.Windows.Media.Media3D;
using Irf.It.Thilo.IpSim;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using NExtensions;

namespace IpSimTests
{
    /// <summary>
    ///This is a test class for IpAoaSensorTest and is intended
    ///to contain all IpAoaSensorTest Unit Tests
    ///</summary>
    [TestClass()]
    public class IpAoaSensorTest
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
        ///A test for IpAoaSensor Constructor
        ///</summary>
        [TestMethod()]
        public void IpAoaSensorConstructorTest()
        {
            var _sim = IpSimCore.Instance;
            _sim.SimulationLength = 21;

            string _name = "test"; // TODO: Initialize to an appropriate value
            IpAoaSensor target = new IpAoaSensor(_name);
            target.UpdateRate = 10;

            _sim.DevtSimulation.Run();
            Assert.IsTrue(_sim.DevtSimulation.Now >= _sim.SimulationLength);
        }

        /// <summary>
        ///A test for TestFov
        ///</summary>
        [TestMethod()]
        [DeploymentItem("IpSim.dll")]
        public void TestFovTest()
        {
            var _rot = new Vector3D(1, 1, 1);
            IpAoaSensor_Accessor target = new IpAoaSensor_Accessor(); // TODO: Initialize to an appropriate value
            //target.Rotation = new System.Windows.Media.Media3D.Quaternion();
            Spherical3D _sph2Obj = new Spherical3D(); // TODO: Initialize to an appropriate value
            bool expected = false; // TODO: Initialize to an appropriate value
            bool actual = false;
            //actual = target.TestFov(_sph2Obj);
            Assert.AreEqual(expected, actual);
            Assert.Inconclusive("Verify the correctness of this test method.");
        }
    }
}