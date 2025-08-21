m5core.lcdClear; % Clear the LCD screen
%Configuration
old_blue_button_status = readDigitalPin(esp32, 'D13'); % Initialize the status of the blue and red buttons
old_red_button_status = readDigitalPin(esp32, 'D14');
xcordinate = 0; % Defining lcd coordinates
ycordinate = 0;
reallyDryValue = 1.4 ; % Defining moisture values for different soil conditions
moistureThreshold =1.3;
saturatedValue = 1.25;
pumpPin = 'D36'; % Defining pins
motorPin = 'D26'; 
configurePin(esp32,"D36","DigitalInput"); % Configure pins for the pump and motor
configurePin(esp32,"D26","DigitalOutput");
on = 1; % Defining Turn on / Shut down value
off = 0;
start_time = tic;
window_size = 30; % Define the time window size for scrolling
figure; % Starting the figure for the graph
axis([0 30 -0.5 1.5]); 
xlabel('Time(s)');
text(0,1,'(Saturated Soil)','Color','red',                                                            FontSize',12);
text(0,0,'(Dry Soil)','Color','red','FontSize',12);
ylabel('Moisture Level');
grid on;
live_plot = animatedline('Color', 'b', 'LineWidth', 2);
hold on;

% Main continous loop to keep the apllication alive
 while true
  lcdClear(m5core) % Clearing screen for next action
  moisture_Voltage = readVoltage(esp32,pumpPin); % Reading the current moisture level from the sensor
  % Determine the status of soil based on moisture voltage and update plot
  if moisture_Voltage >= reallyDryValue
       y = 0;
  elseif moisture_Voltage >= moistureThreshold && moisture_Voltage <= reallyDryValue
       y = 0.5;
  elseif moisture_Voltage < saturatedValue
       y= 1;
  end
  % Menu start
  user_choice = menu('Watering Module','Start the watering module', 'What is the moisture level','Use Manually', 'End');
   if user_choice == 1  % When user chooses to start the watering module
    disp("Starting the water module");
    lcdCursor(m5core,xcordinate,ycordinate); % Taking the cursor at the start of the screen
    lcdPrint(m5core,'Starting the water module');

    % Watering loop based on soil moisture conditions
    while true
        moisture_Voltage = readVoltage(esp32,pumpPin);
         % Determine the status of soil based on moisture voltage and update plot
        if moisture_Voltage >= reallyDryValue
          y = 0;
        elseif moisture_Voltage >= moistureThreshold && moisture_Voltage <= reallyDryValue
          y = 0.5;
        elseif moisture_Voltage < saturatedValue
          y= 1;
        end

     if  moisture_Voltage >= reallyDryValue
          % Soil is very dry, start watering the plant
        ycordinate = ycordinate + 20 ;
        lcdCursor(m5core,xcordinate,ycordinate); % Shifting cursor for the next text in a new line
        lcdPrint(m5core,['Moisture Voltage: ', num2str(moisture_Voltage)]);
        ycordinate = ycordinate + 20 ;
        lcdCursor(m5core,xcordinate,ycordinate); % Shifting cursor for the next text in a new line
        lcdPrint(m5core,'soil is dry, water is pumping') 
        disp(['Moisture Voltage: ', num2str(moisture_Voltage)]);
        disp('soil is dry, water is pumping');
        writeDigitalPin(esp32,motorPin,on); % Turn on
        pause(3); % Pump water for 3 seconds
        writeDigitalPin(esp32,motorPin,off); % Turn off
        pause(3); % Wait for 3 seconds
        lcdClear(m5core); % Clearing screen for next action
        ycordinate = 0 ;
        

         % Plot the live data on the graph
        x = toc(start_time);
        addpoints(live_plot,x,y);
        scatter(x,y,50,'r','filled');
        drawnow;
        % Dynamically adjust the x-axis to create a scrolling effect
        if x > window_size
           xlim([x - window_size, x]); % Shift the view as time progresses
        else
           xlim([0, window_size]); % Keep the initial range
        end
     elseif moisture_Voltage >= moistureThreshold && moisture_Voltage <= reallyDryValue
         % Soil is a little dry, water the plant for a shorter time
        ycordinate = ycordinate + 20 ;
        lcdCursor(m5core,xcordinate,ycordinate); % Shifting cursor for the next text in a new line
        lcdPrint(m5core,['Moisture Voltage: ', num2str(moisture_Voltage)]);
        ycordinate = ycordinate + 20 ;
        lcdCursor(m5core,xcordinate,ycordinate); % Shifting cursor for the next text in a new line
        lcdPrint(m5core,'soil is little dry, water is pumping')
        disp(['Moisture Voltage: ', num2str(moisture_Voltage)]);
        disp('soil is little dry, water is pumping');
        writeDigitalPin(esp32,motorPin,on); % Turn on
        pause(1); % Pump water for 1 seconds
        writeDigitalPin(esp32,motorPin,off); % Turn off
        pause(3); % Wait for 3 seconds
        % Plot the live data on the graph
        x = toc(start_time);
        addpoints(live_plot,x,y);
        scatter(x,y,50,'r','filled');
        drawnow;
        % Dynamically adjust the x-axis to create a scrolling effect
        if x > window_size
           xlim([x - window_size, x]); % Shift the view as time progresses
        else
           xlim([0, window_size]); % Keep the initial range
        end
       

     elseif moisture_Voltage < saturatedValue
         % Soil is wet enough, no need for watering
        ycordinate = ycordinate + 20 ;
        lcdCursor(m5core,xcordinate,ycordinate); % Shifting cursor for the next text in a new line
        lcdPrint(m5core,['Moisture Voltage: ', num2str(moisture_Voltage)]);
        ycordinate = ycordinate + 20 ;
        lcdCursor(m5core,xcordinate,ycordinate); % Shifting cursor for the next text in a new line
        lcdPrint(m5core,'soil is wet enough')
        disp(['Moisture Voltage: ', num2str(moisture_Voltage)]);
        disp('soil is wet enough')
        pause(2); % Wait for 2 seconds
        disp('Try some other time.');
         % Plot the live data on the graph
        x = toc(start_time);
        addpoints(live_plot,x,y);
        scatter(x,y,50,'r','filled');
        drawnow;
        % Dynamically adjust the x-axis to create a scrolling effect
        if x > window_size
           xlim([x - window_size, x]); % Shift the view as time progresses
        else
           xlim([0, window_size]); % Keep the initial range
        end
        break; % Exit the watering module loop
     end
    end

    % If the user wants to check the moisture level
   elseif user_choice == 2
    moisture_Voltage = readVoltage(esp32,pumpPin); % Reading the current moisture level from the sensor
    lcdCursor(m5core,xcordinate,ycordinate); % Shifting cursor for the next text in a new line
    lcdPrint(m5core,['Moisture Voltage: ', num2str(moisture_Voltage)]);
    disp(['Moisture Voltage: ', num2str(moisture_Voltage)]);
    pause(2);
     % Plot the live data on the graph
        x = toc(start_time);
        addpoints(live_plot,x,y);
        scatter(x,y,50,'r','filled');
        drawnow;
        % Dynamically adjust the x-axis to create a scrolling effect
        if x > window_size
           xlim([x - window_size, x]); % Shift the view as time progresses
        else
           xlim([0, window_size]); % Keep the initial range
        end

   elseif user_choice == 3
       % Manual operation using buttons
       run = true ;
           lcdCursor(m5core,xcordinate,ycordinate); % Shifting cursor for the next text in a new line
           lcdPrint(m5core,'Press Blue to start and Red to stop');
           ycordinate = ycordinate + 20; 
           disp('Press Blue to start and Red to stop');

       while run == true 
           new_blue_button_status = readDigitalPin(esp32, 'D13'); % Reading new button status
           new_red_button_status = readDigitalPin(esp32, 'D14'); % Reading new button status

           % Blue button pressed, start motor
           if old_blue_button_status == 1 && new_blue_button_status == 0 % Reading if button wad pressed
                  run = true;
                  lcdCursor(m5core,xcordinate,ycordinate); % Shifting cursor for the next text in a new line
                  lcdPrint(m5core,'Blue Button Pressed. Motor starts working.');
                  disp('Blue Button Pressed. Motor starts working.');
                  writeDigitalPin(esp32,motorPin,on);
                  

           % Red button pressed, stop motor
           elseif old_red_button_status == 1 && new_red_button_status == 0 % Reading if button wad pressed
                 writeDigitalPin(esp32,motorPin,off);
                 run = false;
                 ycordinate = ycordinate + 40 ;
                 lcdCursor(m5core,xcordinate,ycordinate); % Shifting cursor for the next text in a new line
                 lcdPrint(m5core,'Red button pressed. Motor stops working');
                 disp('Red button pressed. Motor stops working');
                 pause(3)
                 
           end
       end
  
   % If the user chooses to exit the program
   elseif user_choice == 4
       disp('Program ending.');
       lcdCursor(m5core,xcordinate,ycordinate);
       lcdPrint(m5core,'Program ending.');
       pause(3);  % Wait for 3 seconds before exiting
      break
   end
   ycordinate = 0; % Reset y-coordinate for next menu display
 end
 
% END OF CODE