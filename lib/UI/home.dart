
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}
// button actions
final actions = [
  {'icon': Icons.arrow_outward, 'text': 'Send'},
  {'icon': Icons.call_received, 'text': 'Receive'},
  {'icon': Icons.add, 'text': 'Add'},];


class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children:[
            SizedBox(height:25),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal:25.0, vertical:35.0),
              child: Text('Welcome',
              textAlign: TextAlign.center,
              style:TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color:Colors.amber
              )
              ),
            ),
      // Balance container
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ClipRRect(
                borderRadius:BorderRadius.circular(20),
                child: Container(
                  height: 250,
                  width: double.infinity,
                  color: Colors.blue,
                  child:Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Available Balance',
                      style: TextStyle(
                        fontSize:20,
                        fontWeight: FontWeight.normal,
                        color: Colors.white
                      ),),
                    ),
                    SizedBox(height:20),
                    Text('\$12,345.67',
                    style:TextStyle(
                      fontSize:36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white
                    ),),
        //Buttons for Send, Receive, Add
                    SizedBox(height:40),
                    Padding(
                      padding: const EdgeInsets.all(25.0),
                      child: GridView.count(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 3.0,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        children:List.generate (3, (index){
                          return ElevatedButton.icon(
                            style:ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(40),
                              ),
                              padding: EdgeInsets.symmetric(vertical:8, horizontal:4),
                            ),
                            
                            onPressed: (){
                            print('${actions[index]}clicked');
                            },
                            //icon for button
                            icon:Icon(actions[index]['icon'] as IconData, 
                            color: Colors.white,
                            size: 16,),
                            //text label
                            label:Text(actions[index]['text'] as String,  style:TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold
                            )

                            
                           
                            )
                            
                           
                          );
                      
                        },)
                      ),
                    )
                      
                   
                    
                  ],
                ),
                
                )
              ),
            ),
            
      
            SizedBox(height:25),
    // Assets container
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    height: 250,
                    width: double.infinity,
                    color: Colors.pink,
                  ),
                ),
              ),
            ),

            SizedBox(height:25),

            
      // Top movers container
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  height: 250,
                  width: double.infinity,
                  color: Colors.pink,
                ),
              ),
            )   
      
          ]
      
        )
      
      ),
    );

      
    
  }
}