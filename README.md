# CMPlayer
This is a console music player for macOS. Find it also downloadable on it's web page http://www.cmplayer.org

The following commands are possible as of this writing:
```
exit, quit, q                                                                   
:: exits application                                                            
next, skip, 'TAB'-key                                                           
:: plays next song                                                              
play, pause, resume                                                             
:: plays, pauses or resumes playback                                            
search [<words>]                                                                
:: searches artist and title for a match. case insensitive                      
search artist [<words>]                                                         
:: searches artist for a match. case insensitive                                
search title [<words>]                                                          
:: searches title for a match. case insensitive                                 
search album [<words>]                                                          
:: searches album name for a match. case insensitive                            
search genre [<words>]                                                          
:: searches genre for a match. case insensitive                                 
search year [<year>]  
:: searches recorded year for a match.                                          
mode off                                                                        
:: clears mode playback. playback now from entire song library                  
help                                                                            
:: shows this help information                                                  
pref                                                                            
:: shows preferences information                                                
about                                                                           
:: show the about information                                                   
genre                                                                           
:: shows all genre information and statistics                                   
year                                                                            
:: shows all year information and statistics                                    
mode                                                                            
:: shows current mode information and statistics                                
repaint                                                                         
:: clears and repaints entire console window 
add mrp <path>                                                                  
:: adds the path to music root folder                                           
remove mrp <path>                                                               
:: removes the path from music root folders                                     
clear mrp                                                                       
:: clears all paths from music root folders                                     
set cft <seconds>                                                               
:: sets the crossfade time in seconds (1-10 seconds)                            
set mf <formats>                                                                
:: sets the supported music formats (separated by ;)                            
enable crossfade                                                                
:: enables crossfade                                                            
disable crossfade                                                               
:: disables crossfade                                                           
enable aos                                                                      
:: enables playing on application startup                                       
disable aos             
:: disables playing on application startup                                      
rebuild songno                                                                  
:: rebuilds song numbers                                                        
goto <mm:ss>                                                                    
:: moves playback point to minutes (mm) and seconds (ss) of current song        
replay                                                                          
:: starts playing current song from beginning again                             
reinitialize                                                                    
:: reinitializes library and should be called after mrp paths are changed       
info                                                                            
:: shows information about first song in playlist                               
info <song no>                                                                  
:: show information about song with given song number                           
update cmplayer                                                                 
:: updates cmplayer if new version is found online                              
set viewtype <type>                                                             
:: sets view type. can be 'default' or 'details'
set theme <color>                                                               
:: sets theme color. color can be 'default', 'blue' or 'black'
```

**NB! THIS SOFTWARE HAS NO LICENSE!**
