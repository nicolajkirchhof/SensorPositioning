using System;
using System.Collections.Generic;
using System.Windows.Documents;
using System.Windows.Media.Media3D;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using NExtensions;

namespace NExtensionsTests
{
    /// <summary>
    ///This is a test class for Spherical3DRangeTest and is intended
    ///to contain all Spherical3DRangeTest Unit Tests
    ///</summary>
    [TestClass()]
    public class Spherical3DRangeTest
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

        private const double DBL_Constant = 0.2;

        /// <summary>
        ///A test for IsInRange
        ///</summary>
        [TestMethod()]
        public void IsInRangeTest()
        {
            SphericalRange3D target = new SphericalRange3D(); // TODO: Initialize to an appropriate value
            target.Direction = new Vector3D(1, 0, 0);
            target.AzimuthRangeDegree = 90;
            target.ElevationRangeDegree = 45;
            target.Rotation = -45;
            target.MaxRange = double.MaxValue;
            target.MinRange = 0;

            //Spherical3D _vector = new Spherical3D(1, -1 + Math.PI / 2, 1 + Math.PI / 2); // TODO: Initialize to an appropriate value
            bool expected = true; // TODO: Initialize to an appropriate value
            bool actual;

            //delegate double del(double x);
            //del _f = x => { return x * 0.1; };

            var _pointsX = new List<Point3D>(100);
            var _resultsX = new List<Vector3D>(100);
            var _successX = new List<bool>(100);
            for (int x = 0; x < 50; x++)
            {
                //for (int z = 0; z < 10; z++)
                //{
                var _f = x * DBL_Constant;
                Vector3D _tmpV3D;
                var _tmpP3D = new Point3D(4, x * DBL_Constant, x * DBL_Constant);
                _successX.Add(target.IsInRange(_tmpP3D, out _tmpV3D));
                _pointsX.Add(_tmpP3D);
                _resultsX.Add(_tmpV3D);
                //}
            }

            target.Direction = new Vector3D(0, 1, 0);
            var _pointsY = new List<Point3D>(100);
            var _resultsY = new List<Vector3D>(100);
            var _successY = new List<bool>(100);
            for (int x = 0; x < 50; x++)
            {
                //for (int z = 0; z < 10; z++)
                //{
                Vector3D _tmpV3D;
                var _tmpP3D = new Point3D(x * DBL_Constant, 4, x * DBL_Constant);
                _successY.Add(target.IsInRange(_tmpP3D, out _tmpV3D));
                _pointsY.Add(_tmpP3D);
                _resultsY.Add(_tmpV3D);
                //}
            }
            //var _point = new Point3D() { X = 0.5, Y = 2, Z = 0.5 };
            ////actual = target.IsInRange(_vector);
            //Vector3D result;
            //actual = target.IsInRange(_point, out result);
            //Assert.AreEqual(expected, actual);
        }
    }
}