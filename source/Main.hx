package;

import flixel.graphics.FlxGraphic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxState;
import flixel.addons.transition.FlxTransitionableState;
import openfl.Assets;
import openfl.Lib;
import openfl.display.FPS;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.system.System;
import cpp.vm.Gc;

#if CRASH_HANDLER
import lime.app.Application;
import openfl.events.UncaughtErrorEvent;
import haxe.CallStack;
import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;
import sys.io.Process;
#end

using StringTools;

class Main extends Sprite {
	public static var initialState:Class<FlxState> = TitleState; // The FlxState the game starts with.
	public static var gameWidth:Int = 1280; // Width of the game in pixels (might be less / more in actual pixels depending on your zoom).
	public static var gameHeight:Int = 720; // Height of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var zoom:Float = -1; // If -1, zoom is automatically calculated to fit the window dimensions.
	var framerate:Int = 60; // How many frames per second the game should run at.
	var skipSplash:Bool = true; // Whether to skip the flixel splash screen that appears in release mode.
	var startFullscreen:Bool = false; // Whether to start the game in fullscreen on desktop targets

	public static var fpsVar:FPS;

	public static var skipNextDump:Bool = false;
	

	public static function main():Void {
		Lib.current.addChild(new Main());
	}

	public function new() {
		super();

		SUtil.gameCrashCheck();
		if (stage != null) {
			init();
		}
		else {
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
	}

	private function init(?E:Event):Void {
		if (hasEventListener(Event.ADDED_TO_STAGE)) {
			removeEventListener(Event.ADDED_TO_STAGE, init);
		}

		setupGame();
	}

	public function setupGame():Void {
                Lib.application.window.onClose.add(PlayState.onWinClose);
		
		SUtil.doTheCheck();
		
		#if !debug
		initialState = TitleState;
		#end
		
		fpsVar = new FPS(10, 4, 0xFFFFFF);
                
		if (fpsVar != null) {
			fpsVar.visible = false;
		}
		
		addChild(new FlxGame(gameWidth, gameHeight, initialState, framerate, framerate, skipSplash, startFullscreen));

		FlxG.signals.preStateSwitch.add(function () {
			if (!Main.skipNextDump) {
				Paths.clearStoredMemory(true);
				FlxG.bitmap.dumpCache();
			}
			clearMajor();
		});
		FlxG.signals.postStateSwitch.add(function () {
			Paths.clearUnusedMemory();
			clearMajor();
			Main.skipNextDump = false;
		});

		
		addChild(fpsVar);
		
		#if html5
		FlxG.autoPause = false;
		#end
	
	        #if CRASH_HANDLER
		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onCrash);
		#end
			
		FlxG.signals.gameResized.add(onResizeGame);
	}

	function onResizeGame(w:Int, h:Int) {
		fixShaderSize(this);
		if (FlxG.game != null) fixShaderSize(FlxG.game);

		if (FlxG.cameras == null) return;
		for (cam in FlxG.cameras.list) {
			@:privateAccess
			if (cam != null && (cam._filters != null || cam._filters != []))
				fixShaderSize(cam.flashSprite);
		}	
	}

	function fixShaderSize(sprite:Sprite) // Shout out to Ne_Eo for bringing this to my attention
	{
		@:privateAccess {
			if (sprite != null)
			{
				sprite.__cacheBitmap = null;
				sprite.__cacheBitmapData = null;
				sprite.__cacheBitmapData2 = null;
				sprite.__cacheBitmapData3 = null;
				sprite.__cacheBitmapColorTransform = null;
			}
		}
	}
	public static function clearMajor() {
		Gc.run(true);
		Gc.compact();
	}
	#if CRASH_HANDLER
	function onCrash(e:UncaughtErrorEvent):Void
	{
		var errMsg:String = "";
		var path:String;
		var callStack:Array<StackItem> = CallStack.exceptionStack(true);
		var dateNow:String = Date.now().toString();

		dateNow = dateNow.replace(" ", "_");
		dateNow = dateNow.replace(":", "'");

		path = "./crash/" + "Mario_" + dateNow + ".txt";

		for (stackItem in callStack)
		{
			switch (stackItem)
			{
				case FilePos(s, file, line, column):
					errMsg += file + " (line " + line + ")\n";
				default:
					Sys.println(stackItem);
			}
		}

		errMsg += "\nUncaught Error: " + e.error + "\nPlease report this error to the GitHub page: https://github.com/ShadowMario/FNF-PsychEngine\n\n> Crash Handler written by: sqirra-rng";

		if (!FileSystem.exists("./crash/"))
			FileSystem.createDirectory("./crash/");

		File.saveContent(path, errMsg + "\n");

		Sys.println(errMsg);
		Sys.println("Crash dump saved in " + Path.normalize(path));

		Application.current.window.alert(errMsg, "Error!");
    #if desktop
		DiscordClient.shutdown();
	 #end
		Sys.exit(1);
	}
	#end
}

