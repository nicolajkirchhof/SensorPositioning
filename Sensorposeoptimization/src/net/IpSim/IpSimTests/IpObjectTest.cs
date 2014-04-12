using System;
using System.Collections.Generic;
using System.Windows.Media.Media3D;
using Irf.It.Thilo.IpSim;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using NExtensions;

namespace IpSimTests
{
    /// <summary>
    ///This is a test class for IpObjectTest and is intended
    ///to contain all IpObjectTest Unit Tests
    ///</summary>
    [TestClass()]
    public class IpObjectTest
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

        internal virtual IpObject CreateIpObject()
        {
            // TODO: Instantiate an appropriate concrete class.
            IpObject target = new IpAoaSensor("test");
            return target;
        }

        /// <summary>
        ///A test for GetAnimatedPose
        ///</summary>
        [TestMethod()]
        public void GetAnimatedPoseTest()
        {
            IpObject target = CreateIpObject(); // TODO: Initialize to an appropriate value
            target.SetKeyframe(0);
            target.Position = new Point3D(1, 1, 1);
            target.Orientation = new AxisAngle3D()
            {
                X = 1,
                Y = 1,
                Z = 1
            };
            target.SetKeyframe(10);

            double time = 0F; // TODO: Initialize to an appropriate value
            Pose3D expected = new Pose3D()
                {
                    Orientation = target.Orientation,
                    Position = target.Position,
                    Time = 10
                }; // TODO: Initialize to an appropriate value
            Pose3D actual;
            var intermediates = new List<Pose3D>();
            for (int i = 0; i < 10; i++)
            {
                intermediates.Add(target.GetAnimatedPose(i));
            }

            actual = target.GetAnimatedPose(10);
            Assert.AreEqual(expected, actual);
            Assert.Inconclusive("Verify the correctness of this test method.");
        }
    }
}