using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using CombinationsGenerator;
using System.Collections;
using System.IO;
namespace CombinationsGeneratorTest
{
    class Program
    {
        static void Main(string[] args)
        {
            var input = new List<byte>(40);
            //uint[] input = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 };
            for (byte i = 0; i < 40; i++) { input.Add(i); }
            var k = 10;

            FileStream fs = File.OpenWrite(String.Format("Combinations_{0}_{1}", input.Count(), k));
            BinaryWriter bw = new BinaryWriter(fs);
            //var numc = input.Count()!/((input.Count()-k)!*k!);

            
            var combinations_array = Generator.Combinations(input, k);
            //foreach(uint num in input)
                //System.Console.WriteLine(string.Join(", ",input));
            //foreach (var comb in combinations_array)
            //{System.Console.WriteLine(string.Join(", ", comb));}

            System.Console.WriteLine("Started writing data to file...");

            foreach (var comb in combinations_array)
            { 
                bw.Write(comb.ToArray()); 
            }

            System.Console.WriteLine("All data was written to file...\n Press Key to exit...");
            var hold = System.Console.ReadLine();

        }
    }
}
