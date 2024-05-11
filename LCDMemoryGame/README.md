# FINAL PROJECT: MemoryGame
  ## Description Of Project Behavior 
  Our project is a memory game. The game is supposed to work where there are 4 arrows, up, down, left, and right. Then these arrows are displayed in a sequence where the first arrow shows, and then waits for the user input. If the user is correct then the same arrow shows and another arrow shows thats next up in the iteration. Then it waits for the user to input those two inputs correctly and so on. We also created a version that uses numbers on the LCD of the board which has the same idea of the game, instead it uses the left middle and right buttons as inputs as the display shows a 1 in either the left middle or right spot. This game is exactly the same as Simon matching color game except we use the buttons on the board as directional arrows
  * In order to run this game you need the following
    1. Digilent Nexys A7 100T FPGA Board
       ![image](/Images/NexysA7.jpg)
       The circle on the top is where you plug the VGA Cable/Adapter in

       The one on left is where the power cable goes

       The one around the buttons are the ones that control you rup down left and right arrows
       
    3. VGA Cable (Or Adapter)

       ![image](/Images/VGA.jpg)
    5. Monitor
  
  ## **Lab 3: Ball** Code Modifications for Arrow Memory
  ### Arrow.vhd
  * To draw the arrows we editied how the ball was drawn in lab 3. First we made a triangle that split the left and right sides of the screen and filled in the space if it was in the area of the triangle. Then we added the rectangle by dividing the ball_x or ball_y by 2 and shifting it up down left or right for the pointer. This is an example of the up arrow, and to change the direction we switched whether it was drawing from left/right or top/down and then changed where the point should be
    ![image](/Images/ArrowCode.png)
    
  * This is also what that up Arrow looked like for example

    ![image](/Images/ArrowTop.jpg)
  * Then we added a color case to match colors to certain integers that when we called 1 it would be red, 2 would be green, and 3 would be blue
    ![image](/Images/ColorCode.png)

  ### Vga_top.vhd
  * First signals are needed to handle the random array for the memory game that houses various inputs that must be compared to the given inputs
  * The singals would be a user index, game index, game array, game array max index
  * Signals are also required for FSM delay, debouncing, and other methods of trying to fix the code

  * Either siginals for display of 1 to 3 in integer array or 1-4 for arrow direction was used for either of the projects
  * Then VGA uses color 1-3 to write to Arrow's color.
  ![image](/Images/ArrowSignals.png)
  
  * Implement Arrow_UP, Arrow_DOWN, Arrow_LEFT, Arrow_RIGHT portmapping
      * Variables for X and Y displacements
      * IF Statement, calls one of four arrow positions and assigns corresponding displacements
   
  
  * For the the FSM created now it generally houses an IDLE, GAME OUTPUT, and USER INPUT press and release states, or display. For the VGA it resets all the variables in idle and houses an extra process to accept a multiple button keybind to reset the game, game output is not compatible with the specific clock as it needs to be governed to display via a middle button press, until of which the array is iterated and index reset after reaching user_input press, where a similar process begings. Without a functioning count it sets arrow_direction on press to display, same with color, then on release and only on release will arrow_direction set to 5 and disappear. Right before the press displays it also checks in unison with the game_output index of the array with the user input delay, these variables work in unison to control the state of the memory game, where the user is in relation with the current game array length that slowly increments, and the user input increments before they are compared.
![image](/Images/ArrowLogic1.png)
![image](/Images/ArrowLogic2.png)
![image](/Images/ArrowLogic3.png)

## **Lab 4: Calculator** Code Modifications for LCD Memory
### hexcalc.vhd

  * The reason for this method to not be used is issues with syncronization between the VGA and the FSM
  * These issues caused for the array to inconsistently skip arround in comparison to using the 50 MHZ clock in the LAB 4 code instead of Lab 3 code where we experienced the most amount of issues.

  * The LCDMemoryGame uses similar signals, as well as a functioning delay count that allows for the sequence to be shown in a near exact 1 second interval. The pros to this is that a middle mouse button is no longer needed to iterate through the given array. while a failed attempt at randomized code is present for vga_top.vhd in memory game.

![image](/Imahes/LCDSignals.png)

  * Next off is reimplementing the user input and output steps, instead of having to compare user input meticuoulsly, it simply grabs a button and index to match one of the 3 buttons correlating to 1 of the 3 displays, of which the sequence display does not have to call ARROW by inputting a different value to ARROW_DIRECTION_FSM and Color_Chosen_FSM, now the code just has to work via the seq_display to directly display a 1 on either the left, middle, or right LCD Display. 

![image](/Images/LCDDisplay.png)

* A synchronization to state switches was also made on top of the FSM for the LCDMemoryGame

* Because of the more automatic and consistently working delay for the LCDMemoryGame's LCD, we had experienced better success in displaying the array, which worked sucessfully but only breaks once the last 3 iterations are displayed, all sucessfully with a second in between. However the problem is that even though the index is working, providing different 1s on the different screen, for 1 showing 0100, 2 showing 0010, and 3 showing 0001, to corrrespond to btn_left for 0100, btn_middle for 0010, and btn_right for 0001 that is then compared in the fsm.

![image](/Images/LCDLogic.png)

## Final Thoughts and Conclusion

* Inputs and Outputs in the VGA Memory Game were changes as we directly influenced arrow direction in an if statement then color chosen to be inputted into arrow from the FSM, where arrow outputs its color on and off to the vga_sync sucessfully creating arrow directions which was a large accomplishment of its own, of then its up to the violation of the FSM to be able to successfully activate the arrows in exactly the right order, of which the stability of the program without delays or debouncing functioning, and buttoon presses not being 100% consistent made troubleshooting the FSM impossible. Buttons as inputs are also added within the vga_top.xdc constraint file.
  
* Working with these projects, we have refined a lot of our knowlege on how ball_draw works with ball_on being NOT red blue or green to flip between drawing for the project. We have demonstrated excessive boolean logic and other syncronization fixes/delays to troubleshoot issues that we have not been able to see much of in the labs as we generally worked with architectures that themselves worked without implementing the entire FSM to code that did not support it. A lot of our emails and explanations back and forth demonstrate our thought process and successes in troubleshooting previous issues up to this point


* There are recordings of the Arrow direction in action, it is also what you (Professor Yett) have seen in action yourself though we have not been able to make the code more consistent and responsible than that point and is also not the primary lab in question.

* Functioning display video for the VGA Memory Game shows the first three arrows display, as well as accepting user input though due to incremental errors with the FSM it will skip arrows, or increment the counter multiple times, giving the wrong array size. However, pressing btn_left, btn_middle, and btn_right will reset the game back to its proper idle state.
  
* LCD DISPLAY ARROWS (Please let me know if this public link share does not give you access)
* https://drive.google.com/file/d/1Xh6_WCQx1JRTh_ypAwYhQE3YZCwcSsoV/view?usp=drive_link
  
## What WAS left to do
  * Generate string of random arrow positions, calls and shows arrows in pattern
  * Accept user inputs and checks for matching arrows, if mismatch found you lose
  * Keep generating longer patterns each time user completes current string of random arrows
  * Keep track of what level the user is on with a counter and display it
  * Display a "C" (Correct) or "F" (Fail) value on one of the open displays when user finishes a level
  * Add more randomness with arrays by flipping switches making it harder for users

## Contributions

### John
* Responsible for FSM creation and troubleshooting
* implementing inputs and outputs of Arrow in VGA and README

### Nick
* Responsible for hand creating the arrow code of which worked flawlessly, Up arrow, down arrow, left arrow, right arrow
* Attempts in debugging FSM for both Arrow and LCD Game
* Writing and Editing README

## Arrow MemoryGame Setup

### 1. Create a new RTL project MemoryGame in Vivado Quick Start

* Create five new source files of file type VHDL called **arrow.vhd**, **vga_top.vhd**, **vga_sync.vhd**, **clk_wiz_0.vhd**, **clk_wiz_0_clk_wiz.vhd**
  
* Create a new constraint file of file type XDC called **vga_top.xdc**

* Choose Nexys A7-100T board for the project

* Click 'Finish'

* Click design sources and copy the VHDL code from arrow.vhd, vga_top.vhd, vga_sync.vhd, clk_wiz_0.vhd, clk_wiz_0_clk_wiz.vhd

* Click constraints and copy the code from vga_top.xdc

* As an alternative, you can instead download files from Github and import them into your project when creating the project. The source file or files would still be imported during the Source step, and the constraint file or files would still be imported during the Constraints step.

### 2. Run synthesis

### 3. Run implementation

### 3b. (optional, generally not recommended as it is difficult to extract information from and can cause Vivado shutdown) Open implemented design

### 4. Generate bitstream, open hardware manager, and program device

* Click 'Generate Bitstream'

* Click 'Open Hardware Manager' and click 'Open Target' then 'Auto Connect'

* Click 'Program Device' then xc7a100t_0 to download vga_top.bit to the Nexys A7 board

---

## LCD MemoryGame Setup

### 1. Create a new RTL project MemoryGame in Vivado Quick Start

* Create two new source files of file type VHDL called **hexcalc.vhd** and **leddec16.vhd**
  
* Create a new constraint file of file type XDC called **hexcalc.xdc**

* Choose Nexys A7-100T board for the project

* Click 'Finish'

* Click design sources and copy the VHDL code from hexcalc.vhd, leddec16.vhd

* Click constraints and copy the code from hexcalc.xdc

* As an alternative, you can instead download files from Github and import them into your project when creating the project. The source file or files would still be imported during the Source step, and the constraint file or files would still be imported during the Constraints step.

### 2. Run synthesis

### 3. Run implementation

### 3b. (optional, generally not recommended as it is difficult to extract information from and can cause Vivado shutdown) Open implemented design

### 4. Generate bitstream, open hardware manager, and program device

* Click 'Generate Bitstream'

* Click 'Open Hardware Manager' and click 'Open Target' then 'Auto Connect'

* Click 'Program Device' then xc7a100t_0 to download vga_top.bit to the Nexys A7 board

* Have Fun!

![HAPPY CAT YAY](https://media.tenor.com/lCKwsD2OW1kAAAAj/happy-cat-happy-happy-cat.gif) ![HAPPY CAT YAY](https://media.tenor.com/lCKwsD2OW1kAAAAj/happy-cat-happy-happy-cat.gif) ![HAPPY CAT YAY](https://media.tenor.com/lCKwsD2OW1kAAAAj/happy-cat-happy-happy-cat.gif) ![HAPPY CAT YAY](https://media.tenor.com/lCKwsD2OW1kAAAAj/happy-cat-happy-happy-cat.gif)
