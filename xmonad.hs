-------------------------------------------------------------------------------
--                  __  ____  __                       _                     --
--                  \ \/ /  \/  | ___  _ __   __ _  __| |                    --
--                   \  /| |\/| |/ _ \| '_ \ / _` |/ _` |                    --
--                   /  \| |  | | (_) | | | | (_| | (_| |                    --
--                  /_/\_\_|  |_|\___/|_| |_|\__,_|\__,_|                    --
--                                                                           --
-------------------------------------------------------------------------------
--          written by Tiago Silva  (https://github.com/Athanasi)            --
-------------------------------------------------------------------------------

import XMonad
import XMonad.Actions.GridSelect
import XMonad.Actions.WithAll
import Control.Monad
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.Script
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.SetWMName
import XMonad.Util.Run(spawnPipe)
import XMonad.Util.EZConfig(additionalKeys)
import XMonad.Util.NamedScratchpad (NamedScratchpad(NS), namedScratchpadManageHook, namedScratchpadAction, customFloating)
import XMonad.Util.SpawnOnce
import System.IO
import Control.Monad
import XMonad.Layout.Circle
import XMonad.Layout.Spiral
import XMonad.Layout.Spacing
import XMonad.Layout.Fullscreen
import XMonad.Layout.Grid
import XMonad.Layout.NoBorders
import XMonad.Util.Loggers
import XMonad.Util.Paste
import qualified XMonad.StackSet as W
import qualified Data.Map as M
import qualified GHC.IO.Handle.Types as H


--------------------------------------------------------------------------
-- workspace --
--------------------------------------------------------------------------

myWorkspaces    :: [String]
myWorkspaces    = clickable $ [ "^i(/home/josech/.xmonad/.icons/term.xbm)  Term "++laycon1++""
                              , "^i(/home/josech/.xmonad/.icons/www.xbm)  Web "++laycon1++""
                              , "^i(/home/josech/.xmonad/.icons/code.xbm)  Code "++laycon1++""
                              , "^i(/home/josech/.xmonad/.icons/file1.xbm)  Archive "++laycon1++""
                              ]
                     where clickable l       = [ "^ca(1,xdotool key super+" ++ show (n) ++ ")" ++ ws ++ "^ca()" |
                                         (i,ws) <- zip [1..] l,
                                         let n = i ]

--------------------------------------------------------------------------
-- style --
--------------------------------------------------------------------------
myLogHook h = do
    dynamicLogWithPP $ tryPP h
tryPP :: Handle -> PP
tryPP h = def
    { ppOutput		= hPutStrLn h
  , ppCurrent 		= dzenColor "#f8f8f8" "#C12B4D" . pad . wrap  " "  " "
  , ppVisible		= dzenColor "#C5C8C6" "#1F1F1F" . pad . wrap  " "  " "
  , ppHidden		= dzenColor "#C5C8C6" "#1F1F1F" . pad . wrap  " "  " "
  , ppHiddenNoWindows	= dzenColor "#C5C8C6" "#1F1F1F" . pad . wrap  " "  " "
  , ppWsSep		= ""
  , ppSep			= " "
  , ppLayout		= dzenColor "#1F1F1F" "#C5C8C6" . wrap  "   "  "   " .
        ( \x -> case x of
        "Spacing 10 Grid"		-> "^ca(1,xdotool key super+space)^i("++laycon++"grid.xbm)^ca()" ++ "   " ++ "Grid"
	"Spacing 10 Spiral"		-> "^ca(1,xdotool key super+space)^i("++laycon++"spiral.xbm)^ca()" ++ "   " ++ "Spiral"
	"Spacing 10 Circle"		-> "^ca(1,xdotool key super+space)^i("++laycon++"circle.xbm)^ca()" ++ "   " ++ "Circle"
	"Spacing 10 Tall"		-> "^ca(1,xdotool key super+space)^i("++laycon++"sptall.xbm)^ca()" ++ "   " ++ "Sptall"
	"Mirror Spacing 10 Tall"	-> "^ca(1,xdotool key super+space)^i("++laycon++"mptall.xbm)^ca()" ++ "   " ++ "Mptall"
        "Full"	                        -> "^ca(1,xdotool key super+space)^i("++laycon++"full.xbm)^ca()" ++ "   " ++ "Full"
        )
        , ppOrder  = \(ws:l:t:_) -> [l,ws]
        }
myScratchpads = 
  -- [ NS "terminal" "urxvtc -name terminal -e tmux attach"     (resource =? "terminal") myPosition
  [ NS "terminal" "urxvt -name terminal"                                                 (resource =? "terminal") myTermPosition
  , NS "tmux-terminal" "urxvt -name tmux-terminal -e sh -c 'tmux attach || tmux new'"            (resource =? "tmux-terminal") myTermPosition
  
  , NS "hackspace" "urxvt -name hackspace -e ssh hackspace -t tmux attach || tmux new"                                                (resource =? "hackspace") myTermPosition
  , NS "quick-nautilus"    "nautilus ~/Documents"                                     (resource =? "quickNautilus") myTermPosition
  , NS "music" "urxvt -name playlist -e ncmpcpp"                             (resource =? "music")    myPositionBiggerSE
    -- , NS "clock" "urxvt -name clock -e ncmpcpp -s clock"                                   (resource =? "clock")    myPositionBiggerSW
    -- , NS "clock" "urxvt -name browser -e ncmpcpp -s browser"                                   (resource =? "browser")    myPositionBiggerSE
    -- , NS "media-library" "urxvt -name media-library -e ncmpcpp -s media-library"           (resource =? "media-library")    myPositionBiggerSE
  , NS "alsa" "urxvt -name alsa -e alsamixer"                                            (resource =? "alsa")    myPositionBiggerSE
  , NS "rtorrent" "urxvt -name rtorrent -e rtorrent"                                     (resource =? "rtorrent") myPosition
  ] where
  myPosition = customFloating $ W.RationalRect (1/3) (1/3) (1/3) (1/3)
  myTermPosition = customFloating $ W.RationalRect (1/3) (1/5) (23/50) (7/20)
  myPositionBiggerSW = customFloating $ W.RationalRect (1/2) (1/2) (1/2) (1/2)  
  myPositionBiggerSE = customFloating $ W.RationalRect (1/5) (1/5) (1/3) (1/3)
  
  
---------------------------------------------------------------------------
-- additional key --
---------------------------------------------------------------------------
myKeys =
  [
    ((mod4Mask, xK_a),
      spawn "firefox")
  , ((mod4Mask, xK_p),
     spawn  "dmenu_path -i -x 415 -y 330 -w 450 -h 20 -l 4 -fn 'Lucida Grande-8' -nb '#1D1F21' -nf '#C5C8C6' -sb '#C12B4D' -sf '#C5C8C6'")
  , ((0, xK_Print),
      spawn "maim ~/Imagens/$(date +%d-%m-%y_%H:%M:%S).png | notify-send -u low 'Screenshot saved to ~/Imagens'")
  , ((mod4Mask, xK_Print),
      spawn "maim -s --showcursor -b 3 ~/Imagens/$(date +%d-%m-%y_%H:%M:%S).png | notify-send -u low 'Screenshot saved to ~/Imagens'")
  , ((mod4Mask, xK_t),
      spawn "nautilus")
  , ((mod4Mask, xK_m),
      spawn "telegram-desktop")
  , ((0, xK_Insert),
      pasteSelection)
  , ((mod4Mask, xK_s),
      spawn "emacs")
  , ((mod4Mask, xK_n),
      spawn "nitrogen")
    --       , ((0, xK_F4), spawn
    --           "xkill")
  , ((mod4Mask, xK_f),
      sinkAll)
  , ((mod4Mask, xK_x),
      killAll)
  , ((mod4Mask, xK_y), spawn
           "xclip -o -se p | xclip -i -se c")
  , ((mod4Mask, xK_Down), spawn
      "amixer -D pulse sset Master 5%-")
  , ((mod4Mask, xK_Up), spawn
                        "amixer -D pulse sset Master 5%+")
  , ((mod4Mask, xK_b), spawn 
                       "brave")
  , ((mod4Mask, xK_q), spawn
                       "killall dzen2; xmonad --recompile; xmonad --restart")
    -- Scratchpads
  , ((mod4Mask, xK_g), namedScratchpadAction myScratchpads "tmux-terminal")
  -- , ("M-g",               namedScratchpadAction myScratchpads "tmux-terminal")
  -- , ("M-S-f",               namedScratchpadAction myScratchpads "quick-nautilus")
  -- , ("M-C-h",               namedScratchpadAction myScratchpads "hackspace")
  -- , ("M-C-h",               namedScratchpadAction myScratchpads "hackspace")
  -- , ("M-M1-b",            namedScratchpadAction myScratchpads "rtorrent")
  , ((mod4Mask, xK_n), namedScratchpadAction myScratchpads "music")
  -- , ("M-S-a",             namedScratchpadAction myScratchpads "alsa")
  ]
  
  
  ---------------------------------------------------------------------------
  -- layout tiling --
---------------------------------------------------------------------------

myLayout = avoidStruts $ smartBorders (  sGrid ||| sSpiral ||| sCircle ||| sTall ||| Mirror sTall ||| Full )
    where
    sTall = spacing 10 $ Tall 1 (1/2) (1/2)
    sGrid = spacing 10 $ Grid
    sCircle = spacing 10 $ Circle
    sSpiral = spacing 10 $ spiral (toRational (2/(1+sqrt(5)::Double)))

---------------------------------------------------------------------------
-- Myapps --
---------------------------------------------------------------------------
myApps = composeAll 
  [ className =? "subl3" --> doFloat
  , className =? "Gimp" --> doFloat
  , className =? "mpv" --> doFloat 
  , className =? "Oblogout" --> doFullFloat
--, className =? "Thunar"   --> doFloat
  , className =? "Viewnior" --> doCenterFloat
  ]

---------------------------------------------------------------------------
-- main code --
---------------------------------------------------------------------------

main = do
    bar <- spawnPipe "dzen2 -p -ta l -e 'button3=' -fn 'Exo 2-7:Bold' -h 21 -w 650"
    bar2 <- spawnPipe "conky -c ~/.xmonad/dzenconky | dzen2 -p -ta r -e 'button3=' -fn 'Exo 2-7:Bold' -x 650 -h 21 -w 716"
    bar3 <- spawnPipe "conky -c ~/.xmonad/conky_dzen2 | dzen2 -p -ta r -e 'button3=' -fn 'Exo 2-7:bold'  -h 21 -w 1500 -y 1220 -x 60"
    bar4 <- spawnPipe "sh /home/josech/.xmonad/Scripts/menu.sh"
    xmonad $ def
        { manageHook = myApps <+>  manageDocks <+> namedScratchpadManageHook myScratchpads <+>manageHook def
    , layoutHook = myLayout 
    , borderWidth = 2
    , normalBorderColor = "#1f1f1f"
    , focusedBorderColor = "red"
    , terminal = "urxvt"
    , workspaces = myWorkspaces
    , modMask = mod4Mask
    , startupHook = setWMName "xmonad"
    , logHook = myLogHook bar
        } `additionalKeys` myKeys  
     where


dzenbar	= "dzen2 -p -ta l -e 'button3=' -fn '" ++ dzenFont  ++ "' -h 21 -w 650"
dzenFont = "Exo 2-7:Bold"
laycon   = "/home/josech/.xmonad/.icons/"
laycon1 = " ^i(/home/josech/.xmonad/.icons/)"

