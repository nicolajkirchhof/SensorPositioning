using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Irf.It.Thilo.DevtSim;

namespace Irf.It.Thilo.DevtSim
{
    /// <summary>
    /// This class handles issues related with random number generation.
    /// @author Arda Ceylan
    /// </summary>
    public abstract class RandomGenerate
    {
        /// <summary>
        /// Is used to generate random numbers.
        /// </summary>
        protected static Random rnd;

        /// <summary>
        /// Constructs a new RandomGenerate.
        /// </summary>
        /// <param name="seed"> Is used as a seed for Random type variable. </param>
        protected RandomGenerate(int seed)
        {
            RandomGenerate.rnd = new Random(seed);
        }

        /// <summary>
        /// Constructs a new RandomGenerate.
        /// </summary>
        protected RandomGenerate()
        {
            RandomGenerate.rnd = new Random();
        }

        public abstract double ComputeValue();
    }

    public class GenerateBool : RandomGenerate
    {
        public GenerateBool(double _criticalValue)
        {
            this.CriticalValue = _criticalValue;
        }

        /// <summary>
        /// Generates a boolean value considering the success rate.
        /// </summary>
        /// <param name="criticalValue"></param>
        /// <returns></returns>
        public double CriticalValue
        {
            get;
            private set;
        }

        /// <summary>
        /// Generates a boolean value considering the success rate.
        /// </summary>
        /// <param name="criticalValue"></param>
        /// <returns></returns>
        public static bool GetBool(double criticalValue)
        {
            bool value = true;
            if (rnd.NextDouble() < criticalValue)
                value = false;
            return value;
        }

        public override double ComputeValue()
        {
            return GetBool(this.CriticalValue) ? 1d : 0d;
        }
    }

    /// <summary>
    /// Generates a boolean value considering the success rate.
    /// </summary>
    /// <param name="criticalValue"></param>
    /// <returns></returns>
    public class GenerateInteger : RandomGenerate
    {
        public GenerateInteger(int _criticalValue)
        {
            this.CriticalValue = _criticalValue;
        }

        public int CriticalValue
        {
            get;
            set;
        }

        /// <summary>
        /// Generates an integer value between 0 and provided value.
        /// </summary>
        /// <param name="criticalValue"></param>
        /// <returns></returns>
        public static int GetInteger(int criticalValue)
        {
            int value = 0;
            value = rnd.Next(criticalValue);
            return value;
        }

        public override double ComputeValue()
        {
            return (double)GetInteger(this.CriticalValue);
        }
    }

    /// <summary>
    /// Produce a uniform random sample from the open interval (0, 1) or (Min, Max).
    /// </summary>
    public class GenerateUniform : RandomGenerate
    {
        public double Min
        {
            get;
            set;
        }

        public double Max
        {
            get;
            set;
        }

        /// <summary>
        /// Produce a uniform random sample from the open interval (0, 1).
        /// </summary>
        /// <returns></returns>
        public static double GetUniform()
        {
            return rnd.NextDouble();
        }

        /// <summary>
        /// Produce a random sample from the open interval (a, b).
        /// </summary>
        /// <param name="a"></param>
        /// <param name="b"></param>
        /// <returns></returns>
        public static double GetUniform(double a, double b)
        {
            return a + rnd.NextDouble() * (b - a);
        }

        public GenerateUniform()
        {
            this.Max = double.NaN;
            this.Min = double.NaN;
        }

        public override double ComputeValue()
        {
            if (!double.IsNaN(this.Min))
            {
                if (!double.IsNaN(this.Max))
                {
                    return GenerateUniform.GetUniform(this.Min, this.Max);
                }
                return this.Min + GenerateUniform.GetUniform();
            }
            return GenerateUniform.GetUniform();
        }
    }

    public class GenerateConstant : RandomGenerate
    {
        public double Delay { get; private set; }

        public GenerateConstant(double _delay)
        {
            this.Delay = _delay;
        }

        public override double ComputeValue()
        {
            return this.Delay;
        }
    }

    /// <summary>
    /// Get normal (Gaussian) random sample with mean 0 and standard deviation 1
    /// </summary>
    public class GenerateNormal : RandomGenerate
    {
        public double Mean
        {
            get;
            set;
        }

        private double std;

        public double Std
        {
            get
            {
                return std;
            }
            set
            {
                if (value < 0.0)
                {
                    throw new ArgumentOutOfRangeException("std must be greater then zero");
                }
                std = value;
            }
        }

        /// <summary>
        /// Get normal (Gaussian) random sample with mean 0 and standard deviation 1
        /// </summary>
        /// <returns></returns>
        public static double GetNormal()
        {
            // Use Box-Muller algorithm
            double u1 = GenerateUniform.GetUniform();
            double u2 = GenerateUniform.GetUniform();
            double r = Math.Sqrt(-2.0 * Math.Log(u1));
            double theta = 2.0 * Math.PI * u2;
            return r * Math.Sin(theta);
        }

        public GenerateNormal()
            : this(double.NaN, double.NaN)
        {
        }

        public GenerateNormal(double _mean, double _std)
        {
            this.Mean = _mean;
            this.Std = _std;
        }

        /// <summary>
        ///  Get normal (Gaussian) random sample with specified mean and standard deviation
        /// </summary>
        /// <param name="mean"></param>
        /// <param name="standardDeviation"></param>
        /// <returns></returns>
        public static double GetNormal(double mean, double standardDeviation)
        {
            if (standardDeviation < 0.0)
            {
                string msg = string.Format("Standard Deviation must be positive. Received {Negative}.", standardDeviation);
                throw new ArgumentOutOfRangeException(msg);
            }
            return mean + standardDeviation * GetNormal();
        }

        public override double ComputeValue()
        {
            if (!double.IsNaN(this.Mean))
            {
                if (!double.IsNaN(this.Std))
                {
                    return GenerateNormal.GetNormal(this.Mean, this.Std);
                }
                return this.Mean + GenerateNormal.GetNormal();
            }
            return GenerateNormal.GetNormal();
        }
    }

    /// <summary>
    /// Get exponential random sample with specified mean
    /// </summary>
    public class GenerateExponential : RandomGenerate
    {
        public double Mean
        {
            get;
            set;
        }

        public GenerateExponential()
        {
            this.Mean = double.NaN;
        }

        /// <summary>
        /// Get exponential random sample with mean 1
        /// </summary>
        /// <returns></returns>
        public static double GetExponential()
        {
            return Math.Log(rnd.NextDouble());
        }

        /// <summary>
        /// Get exponential random sample with specified mean
        /// </summary>
        /// <param name="mean"></param>
        /// <returns></returns>
        public static double GetExponential(double mean)
        {
            return -mean * Math.Log(rnd.NextDouble());
        }

        public override double ComputeValue()
        {
            if (!double.IsNaN(this.Mean))
            {
                return GenerateExponential.GetExponential(this.Mean);
            }
            return GenerateExponential.GetExponential();
        }
    }

    /// <summary>
    /// Get exponential random sample with specified mean
    /// </summary>
    public class GenerateGamma : RandomGenerate
    {
        private GenerateNormal normal = new GenerateNormal();
        private GenerateUniform uniform = new GenerateUniform();

        public GenerateGamma(double _shape, double _scale)
        {
            this.Shape = _shape;
            this.Scale = _scale;
        }

        public double Shape
        {
            get;
            set;
        }

        public double Scale
        {
            get;
            set;
        }

        /// <summary>
        /// Get gamma random sample with parameters
        /// </summary>
        /// <param name="shape"></param>
        /// <param name="scale"></param>
        /// <returns></returns>
        public static double GetGamma(double shape, double scale)
        {
            // Implementation based on "A Simple Method for Generating Gamma Variables"
            // by George Marsaglia and Wai Wan Tsang.  ACM Transactions on Mathematical Software
            // Vol 26, No 3, September 2000, pages 363-372.

            double d, c, x, xsquared, v, u;

            if (shape >= 1.0)
            {
                d = shape - 1.0 / 3.0;
                c = 1.0 / Math.Sqrt(9.0 * d);
                for (; ; )
                {
                    do
                    {
                        x = GenerateNormal.GetNormal();
                        v = 1.0 + c * x;
                    }
                    while (v <= 0.0);
                    v = v * v * v;
                    u = GenerateUniform.GetUniform();
                    xsquared = x * x;
                    if (u < 1.0 - .0331 * xsquared * xsquared || Math.Log(u) < 0.5 * xsquared + d * (1.0 - v + Math.Log(v)))
                        return scale * d * v;
                }
            }
            else if (shape <= 0.0)
            {
                string msg = string.Format("Shape must be positive. Received {0}.", shape);
                throw new ArgumentOutOfRangeException(msg);
            }
            else
            {
                double g = GetGamma(shape + 1.0, 1.0);
                double w = GenerateUniform.GetUniform();
                return scale * g * Math.Pow(w, 1.0 / shape);
            }
        }

        public override double ComputeValue()
        {
            return GetGamma(this.Shape, this.Scale);
        }
    }

    //internal class nervnit
    //{
    //    /// <summary>
    //    /// Get Chi Square random sample with parameter
    //    /// </summary>
    //    /// <param name="degreesOfFreedom"></param>
    //    /// <returns></returns>
    //    public static double GetChiSquare(double degreesOfFreedom)
    //    {
    //        // A chi squared distribution with n degrees of freedom
    //        // is a gamma distribution with shape n/2 and scale 2.
    //        return GetGamma(0.5 * degreesOfFreedom, 2.0);
    //    }

    //    /// <summary>
    //    /// Get inverse gamma random sample with parameters
    //    /// </summary>
    //    /// <param name="shape"></param>
    //    /// <param name="scale"></param>
    //    /// <returns></returns>
    //    public static double GetInverseGamma(double shape, double scale)
    //    {
    //        return 1.0 / GetGamma(shape, 1.0 / scale);
    //    }

    //    /// <summary>
    //    /// Get weibull random sample with parameters
    //    /// </summary>
    //    /// <param name="shape"></param>
    //    /// <param name="scale"></param>
    //    /// <returns></returns>
    //    public static double GetWeibull(double shape, double scale)
    //    {
    //        if (shape <= 0.0 || scale <= 0.0)
    //        {
    //            string msg = string.Format("Shape and scale parameters must be positive. Recieved shape {0} and scale{1}.", shape, scale);
    //            throw new ArgumentOutOfRangeException(msg);
    //        }
    //        return scale * Math.Pow(-Math.Log(GetUniform()), 1.0 / shape);
    //    }

    //    /// <summary>
    //    /// Get cauchy random sample with parameters
    //    /// </summary>
    //    /// <param name="median"></param>
    //    /// <param name="scale"></param>
    //    /// <returns></returns>
    //    public static double GetCauchy(double median, double scale)
    //    {
    //        if (scale <= 0)
    //        {
    //            string msg = string.Format("Scale must be positive. Received {0}.", scale);
    //            throw new ArgumentException(msg);
    //        }

    //        double p = GetUniform();

    //        // Apply inverse of the Cauchy distribution function to a uniform
    //        return median + scale * Math.Tan(Math.PI * (p - 0.5));
    //    }

    //    /// <summary>
    //    /// Get student T random sample with parameters
    //    /// </summary>
    //    /// <param name="degreesOfFreedom"></param>
    //    /// <returns></returns>
    //    public static double GetStudentT(double degreesOfFreedom)
    //    {
    //        if (degreesOfFreedom <= 0)
    //        {
    //            string msg = string.Format("Degrees of freedom must be positive. Received {0}.", degreesOfFreedom);
    //            throw new ArgumentException(msg);
    //        }

    //        // See Seminumerical Algorithms by Knuth
    //        double y1 = GetNormal();
    //        double y2 = GetChiSquare(degreesOfFreedom);
    //        return y1 / Math.Sqrt(y2 / degreesOfFreedom);
    //    }

    //    /// <summary>
    //    /// Get laplace random sample with parameters
    //    /// The Laplace distribution is also known as the double exponential distribution.
    //    /// </summary>
    //    /// <param name="mean"></param>
    //    /// <param name="scale"></param>
    //    /// <returns></returns>
    //    public static double GetLaplace(double mean, double scale)
    //    {
    //        double u = GetUniform();
    //        return (u < 0.5) ?
    //            mean + scale * Math.Log(2.0 * u) :
    //            mean - scale * Math.Log(2 * (1 - u));
    //    }

    //    /// <summary>
    //    /// Get LogNormal random sample with parameters
    //    /// </summary>
    //    /// <param name="mu"></param>
    //    /// <param name="sigma"></param>
    //    /// <returns></returns>
    //    public static double GetLogNormal(double mu, double sigma)
    //    {
    //        return Math.Exp(GetNormal(mu, sigma));
    //    }

    //    /// <summary>
    //    /// Get beta random sample with parameters
    //    /// </summary>
    //    /// <param name="a"></param>
    //    /// <param name="b"></param>
    //    /// <returns></returns>
    //    public static double GetBeta(double a, double b)
    //    {
    //        if (a <= 0.0 || b <= 0.0)
    //        {
    //            string msg = string.Format("Beta parameters must be positive. Received {0} and {1}.", a, b);
    //            throw new ArgumentOutOfRangeException(msg);
    //        }
    //        // There are more efficient methods for generating beta samples.
    //        // However such methods are a little more efficient and much more complicated.
    //        // For an explanation of why the following method works, see
    //        // http://www.johndcook.com/distribution_chart.html#gamma_beta
    //        double u = GetGamma(a, 1.0);
    //        double v = GetGamma(b, 1.0);
    //        return u / (u + v);
    //    }
}