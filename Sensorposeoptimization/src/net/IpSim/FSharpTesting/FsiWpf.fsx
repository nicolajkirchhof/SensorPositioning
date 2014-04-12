#light

#if INTERACTIVE
#r "WindowsBase"
#r "PresentationCore"
#r "PresentationFramework"
#r "System.Xaml"
#r "..\packages\OxyPlot.Wpf.2012.2.1.76\lib\OxyPlot.dll"
#r "..\packages\OxyPlot.Wpf.2012.2.1.76\lib\OxyPlot.Wpf.dll"
#endif 

open System
open System.Windows
open System.Windows.Controls
open System.Threading
open System.Windows.Threading
open OxyPlot
open OxyPlot.Wpf

type MyWnd() = 
    inherit Window()
      
    
//let mywnd = { new Window() with member model = } 


// create a reference to a WPF control in interactive window
let vm = OxyPlot.Wpf.Plot()
let wp = new PlotModel()
wp.Axes.Add(new LinearAxis());
wp.Axes.Add(new LinearAxis());
let cs = new LineSeries(Title = "data")
cs.Points.Add(new DataPoint(1.0, 1.0))
cs.Points.Add(new DataPoint(2.0, 2.0))
wp.Series.Add(cs)

// create a new WPF gui thread with a running dispatcher and message pump
let thread = new System.Threading.Thread(fun() -> 
    let window = new System.Windows.Window(Name="Test",Width=500.0,Height=500.0)
//    wp <- new TextBlock()
//    wp.Text <- "test1"
    
    window.Content <- wp
    window.Visibility <- Visibility.Visible
    window.Show()
    window.Closed.Add(fun e -> 
        Dispatcher.CurrentDispatcher.BeginInvokeShutdown(DispatcherPriority.Background)
        Thread.CurrentThread.Abort())
    Dispatcher.Run()
    )
thread.SetApartmentState(ApartmentState.STA)
//thread.IsBackground <- true

// start the thread, which will invoke the popup ui
thread.Start()

// once WPF window is up, you can marshall updates via its running dispatcher
//wp.Dispatcher.BeginInvoke(Action(fun _ -> wp.Text <- "test2")) |> ignore