// Copyright (c) Microsoft Corporation 2005-2008.  .

module Intermediate
open Sample.Support
open System
open System.Collections.Generic

//--------------------------------------------------------

  
[<Category("Arithmetic");
  Title("Bitwise Integer Operations");
  Description("This sample shows how to use the bitwise integer operations")>]
let Sample4() =
    // Operators over integers:
    let x1 = 0xAB7F3456 &&& 0xFFFF0000 
    let x2 = 0xAB7F3456 ||| 0xFFFF0000 
    let x3 = 0x12343456 ^^^ 0xFFFF0000 
    let x4 = 0x1234ABCD <<< 1 
    let x5 = 0x1234ABCD >>> 16 

    // Also over other integral types, e.g. Int64:
    let x6 = 0x0A0A0A0A012343456L &&& 0x00000000FFFF0000L 

    // Also over other integral types, e.g. unsigned Int64:
    let x6u = 0x0A0A0A0A012343456UL &&& 0x0000FFFF00000000UL 

    // And bytes:
    let x7 = 0x13uy &&& 0x11uy 

    // Now print the results:
    printfn "x1 = 0x%08x" x1;
    printfn "x2 = 0x%08x" x2;
    printfn "x3 = 0x%08x" x3;
    printfn "x4 = 0x%08x" x4;
    printfn "x5 = 0x%08x" x5;
    printfn "x6 = 0x%016x" x6;
    printfn "x6u = 0x%016x" x6u;
    printfn "x7 = 0x%02x" (int x7)
  
  
  
[<Category("Data Types");
  Title("Using the Set type");
  Description("Create a set of particular unicode characters using a Microsoft.FSharp.Collections.Set.")>]
let SampleSet1() =
    let data = "The quick brown fox jumps over the lazy dog" 
    let set = 
        data.ToCharArray()
        |> Set.ofSeq
    for c in set do 
        printfn "Char : '%c'" c 
  

[<Category("Data Types");
  Title("Using the Map type");
  Description("Create a histogram of the occurrences of particular unicode characters using a Microsoft.FSharp.Collections.Map.")>]
let SampleMap1() =
    let data = "The quick brown fox jumps over the lazy dog" 
    let histogram = 
        data.ToCharArray()
        |> Seq.groupBy (fun c -> c)
        |> Map.ofSeq
        |> Map.map (fun k v -> Seq.length v)
    for (KeyValue(c,n)) in histogram do 
        printfn "Number of '%c' characters = %d" c n 
  
  
[<Support("InterfaceSample3")>]
let dummy4() = ()
type IPoint = 
    abstract X : float
    abstract Y : float


/// Implementing an interface with an object expression.
let Point(x,y) =
    { new IPoint with 
         member obj.X=x 
         member obj.Y=y }

/// Implementing an interface with an object expression that has mutable state
let MutablePoint(x,y) =
    let currX = ref x 
    let currY = ref y
    { new IPoint with 
         member obj.X= currX.Value 
         member obj.Y= currY.Value }

/// This interface is really just a function since it only has one 
/// member, but we give it a name here as an example. It represents 
/// a function from some variable to (X,Y)
type ILine = 
    abstract Get : float -> IPoint

/// Implementing an interface with an object expression.
///
/// Here a line is specified by gradient/intercept
let Line(a:float,c:float) = 
    let y(x) = a * x + c
    { new ILine with 
        member l.Get(x) = Point(x, y(x)) }
 
/// Implementing an interface with a class.
///
/// Here a line is specified by gradient/intercept
type GradientInterceptLine(a:float,c:float) = 
    // Some local bindings
    let y(x) = a * x + c

    // Publish additional properties of the object
    member x.Gradient = a
    member x.Intercept = c

    // Also implement the interface
    interface ILine with 
        member l.Get(x) = Point (x,y(x))

[<Category("Defining Types");
  Title("Using interfaces");
  Description("A longer sample showing how to use interfaces to model 'data' objects such as abstract points.  Somewhat contrived, since multiple repreentations of points are unlikely practice, but for larger computational objects maintaining flexibility of representation through using interfaces or function values is often crucial.")>]
/// Using the above types
let InterfaceSample3() =
    
    // This creates an object using a function
    let line1 = Line(1.0, 0.344)

    // This creates a similar object using a type. 
    let line2 = new GradientInterceptLine(2.0,1.5) :> ILine 
    let origin =  { new IPoint with 
                        member p.X =0.0 
                        member p.Y = 0.0 }
    let point1 = line1.Get(-1.0)
    let point2 = line2.Get(0.0)
    let point3 = line2.Get(1.0)
    let outputPoint os (p:IPoint) = fprintf os "(%f,%f)" p.X p.Y 
    printfn "origin = %a" outputPoint origin;
    printfn "point1 = %a" outputPoint point1;
    printfn "point2 = %a" outputPoint point2;
    printfn "point3 = %a" outputPoint point3

        
[<Category("Input/Output");
  Title("Lazily Enumerate CSV File");
  Description("Build an IEnumerable<string list> for on-demand reading of a CSV file using .NET I/O utilities and abstractions")>]
let EnumerateCSVFile1() = 

    // Write a test file
    System.IO.File.WriteAllLines(@"test.csv", [| "Desmond, Barrow, Market Place, 2"; 
                                                 "Molly, Singer, Band, 12" |]);

    /// This function builds an IEnumerable<string list> object that enumerates the CSV-split
    /// lines of the given file on-demand 
    let CSVFileEnumerator(fileName) = 

        // The function is implemented using a sequence expression
        seq { use sr = System.IO.File.OpenText(fileName)
              while not sr.EndOfStream do
                 let line = sr.ReadLine() 
                 let words = line.Split [|',';' ';'\t'|] 
                 yield words }

    // Now test this out on our test file, iterating the entire file
    let test = CSVFileEnumerator(@"test.csv")  
    printfn "-------Enumeration 1------";
    test |> Seq.iter (string >> printfn "line %s");
    // Now do it again, this time determining the numer of entries on each line.
    // Note how the file is read from the start again, since each enumeration is 
    // independent.
    printfn "-------Enumeration 2------";
    test |> Seq.iter (Array.length >> printfn "line has %d entries");
    // Now do it again, this time determining the numer of entries on each line.
    // Note how the file is read from the start again, since each enumeration is 
    // independent.
    printfn "-------Enumeration 3------";
    test |> Seq.iter (Array.map (fun s -> s.Length) >> string >> printfn "lengths of entries: %s")
        
