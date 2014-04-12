#light 
 
open System
open System.Windows
open System.Windows.Controls
open System.Windows.Input
open System.Windows.Media 
 
let mutable itemChecked:MenuItem = null
 
let dck = new DockPanel()
 
let wndw = new Window(Title="Different Window Styles",
                        SizeToContent = SizeToContent.WidthAndHeight,
                        Content=dck) 
 
// This will Create the MenuItem objects to change WindowStyle
let stylItm = new MenuItem(Header="_WindowStyle");
 
// This will Add window styles menu items
[("_Window Without Border", WindowStyle.None);
 ("_Window with Single Border",WindowStyle.SingleBorderWindow);
 ("_Window with 3D Border",WindowStyle.ThreeDBorderWindow);
 ("_Window with Tool",WindowStyle.ToolWindow)]
 |> Seq.iter (fun (str,style) ->
      let cmpnt = new MenuItem(Header=str,
                              Tag=style,
                              IsChecked= (style=wndw.WindowStyle))
      if cmpnt.IsChecked then itemChecked <- cmpnt
      cmpnt.Click.Add( fun _ ->
         itemChecked.IsChecked <- false
         cmpnt.IsChecked <- true
         wndw.WindowStyle <-(cmpnt.Tag :?> WindowStyle)
         itemChecked <- cmpnt)
         
      stylItm.Items.Add(cmpnt) |> ignore)
      
// This will Add Style menu to dock panel
let nwmnu = new Menu()
nwmnu.Items.Add(stylItm)|>ignore
dck.Children.Add(nwmnu)|>ignore
DockPanel.SetDock(nwmnu, Dock.Top)
   
//This will Add TextBlock to DockPanel
dck.Children.Add
   (new TextBlock(Text=wndw.Title,
                  FontSize=25.0,
                  TextAlignment = TextAlignment.Center)
   ) |> ignore
 
 
#if COMPILED
[<STAThread()>]
[<EntryPoint>]
do 
    let app =  Application() in
    app.Run(wndw) |> ignore
#endif


