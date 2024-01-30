package;

#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxCamera;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.effects.FlxFlicker;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.math.FlxMath;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import haxe.ValueException;
import lime.utils.Assets;
import openfl.Lib;
import openfl.desktop.Clipboard;
import openfl.filters.ShaderFilter;

using StringTools;

class WarpState extends MusicBeatState
{
	var tween:FlxTween;
	var tween2:FlxTween;
	var thetimer:FlxTimer;
	public static var curSelected:Int = 0;
	public static var worldSelected:Int = 0;
	public static var unlockpath:Bool = false;
	public static var time:Float = 1;
	var world:Int = 0;
	public static var startCut:Bool = false;
	public static var pipeCut:Bool = false;
	public static var isPico:Bool = false;
	var curDeg:Int = 0;
	var debugmode:Bool = false;
	var quieto:Bool = false;
	var canPress:Bool = false;
	var whatsong:String = '';
	var effect:SMWPixelBlurShader;
	public static var blackScreen:FlxSprite;
	final starNeed:Array<Int> = [3, 7, 5, 6, 3];

	private var grpOptions:FlxTypedGroup<Alphabet>;
	private var iconArray:Array<AttachedSprite> = [];

	private static var canciones:Array<Dynamic> = [
		// Name, 				UP, DOWN, LEFT, RIGHT
		['Start', 				'X', 'X', 'X', '1'],
		['Irregularity Isle',		'X', 'X', '0', '2'],
		['Woodland of Lies',	'X', 'X', '1', '3'],
		['Content Cosmos',			'X', 'X', '2', '4'],
		["Hellish Heights", 	'X', 'X', '3', '5'],
		['Classified Castle',	'X', 'X', '4', 'X']
	];

	private var starPos:Array<Dynamic> = [
		[435, 298],
		[528, 310],
		[624, 310],
		[720, 310],
		[816, 310],
		[912, 310],
	];

	var bg:FlxSprite;
	var bgworld:FlxSprite;
	var introBox:FlxSprite;
	var introButton:FlxSprite;
	var bfAnim1:FlxSprite;
	var pibemapa:FlxSprite;
	var bgWarps:FlxSprite;
	var gameLives:FlxSprite;
	var cartel:FlxSprite;
	var descText:FlxText;
	var worldText:FlxText;
	var screenText:FlxText;
	var hubDots:FlxTypedSpriteGroup<FlxSprite>;

	public var vcr:CRTShader;

	//te presento a mi wawa está lleno de Arrays y else if
	override function create()
	{
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Overworld", null);
		Lib.application.window.title = "Friday Night Funkin': Mario's Madness";
		#end
		FlxG.mouse.visible = false;
		FlxG.mouse.load(TitleState.mouse.pixels, 2);

		var backbg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(blackScreen);

		bg = new FlxSprite(0, 0);
		bg.frames = Paths.getSparrowAtlas('warpzone/0/water_hub');
		bg.animation.addByPrefix('idle', "water hub idle", 6);
		bg.animation.play('idle');
		bg.setGraphicSize(Std.int(bg.width * 3));
		bg.antialiasing = false;
		bg.screenCenter();
		add(bg);

		bgworld = new FlxSprite(0, 0);
		bgworld.loadGraphic(Paths.image('warpzone/0/world'));
		bgworld.setGraphicSize(Std.int(bgworld.width * 3));
		bgworld.antialiasing = false;
		bgworld.screenCenter();
		add(bgworld);

		bgWarps = new FlxSprite(0, 0);
		bgWarps.frames = Paths.getSparrowAtlas('warpzone/0/hub_path');
		bgWarps.setGraphicSize(Std.int(bgWarps.width * 3));
		bgWarps.updateHitbox();
		bgWarps.screenCenter();
		bgWarps.antialiasing = false;
		bgWarps.y = Std.int(bgWarps.y);
		add(bgWarps);

		hubDots = new FlxTypedSpriteGroup<FlxSprite>();
		for (i in 0...canciones.length)
		{
			var dot:FlxSprite = new FlxSprite(starPos[i][0], starPos[i][1]);
			dot.frames = Paths.getSparrowAtlas('warpzone/star');
			if(i == 0){
				if(!ClientPrefs.storySave[7] && ClientPrefs.storySave[6]){
					dot.frames = Paths.getSparrowAtlas('warpzone/pibby');
					dot.setPosition(417, 260);
				}else{
					dot.frames = Paths.getSparrowAtlas('warpzone/pipegray');
				}
			
		
			}
			dot.antialiasing = false;
			dot.setGraphicSize(Std.int(dot.width * 3));
			dot.ID = i;
			dot.animation.addByPrefix("anim", "idle", 6, true);
			dot.animation.addByPrefix("sleep", "sleep", 6, true);
			dot.animation.play("anim");

			if(i >= 2){

				if(ClientPrefs.worlds[(i - 2)] < starNeed[(i - 2)]){
					dot.animation.play('sleep');
				}
			}

			hubDots.add(dot);
		}
		add(hubDots);

		pibemapa = new FlxSprite(400, 251);
		var deadSuffix = '';
		if(ClientPrefs.storySave[7]) deadSuffix = 'dead_';
		pibemapa.frames = Paths.getSparrowAtlas('warpzone/' + deadSuffix + 'overworld_bf');
		pibemapa.animation.addByPrefix('idle', "overworld bf walk down", 6);
		pibemapa.animation.addByPrefix('up', "overworld bf walk up", 6);
		pibemapa.animation.addByPrefix('down', "overworld bf walk down", 6);
		pibemapa.animation.addByPrefix('left', "overworld bf walk left", 6);
		pibemapa.animation.addByPrefix('right', "overworld bf walk right", 6);
		pibemapa.animation.addByPrefix('start', "overworld bf level start", 6);
		pibemapa.animation.add('warp', [0, 5, 9, 13], 10);
		pibemapa.animation.play('idle');
		pibemapa.setGraphicSize(Std.int(pibemapa.width * 3));
		pibemapa.antialiasing = false;
		pibemapa.visible = false;
		pibemapa.updateHitbox();
		add(pibemapa);

		bfAnim1 = new FlxSprite(412, 230);
		bfAnim1.frames = Paths.getSparrowAtlas('warpzone/bfAnims/bfoverworldintro');
		bfAnim1.animation.addByIndices('nothing', "bfoverworldintro idle", [0], "", 6);
		bfAnim1.animation.addByPrefix('idle', "bfoverworldintro idle", 12, false);
		bfAnim1.animation.play('nothing');
		bfAnim1.setGraphicSize(Std.int(bfAnim1.width * 3));
		bfAnim1.antialiasing = false;
		bfAnim1.updateHitbox();
		bfAnim1.visible = true;
		add(bfAnim1);

		gameLives = new FlxSprite(0, 0);
		gameLives.frames = Paths.getSparrowAtlas('warpzone/overworld_overlay');
		gameLives.animation.addByPrefix('idle', "overworld overlay idle", 6);
		gameLives.animation.play('idle');
		gameLives.setGraphicSize(Std.int(gameLives.width * 3));
		gameLives.antialiasing = false;
		gameLives.updateHitbox();
		gameLives.screenCenter();
		add(gameLives);

		var blackBar0:FlxSprite = new FlxSprite().makeGraphic(500, FlxG.height, FlxColor.BLACK);
		blackBar0.alpha = 1;
		blackBar0.x = -244;
		blackBar0.scrollFactor.set(0, 0);
		add(blackBar0);

		var blackBar1:FlxSprite = new FlxSprite().makeGraphic(500, FlxG.height, FlxColor.BLACK);
		blackBar1.alpha = 1;
		blackBar1.x = 1024;
		blackBar1.scrollFactor.set(0, 0);
		add(blackBar1);

		descText = new FlxText(0, 20, 400, "DEBUG", 16);
		descText.visible = false;
		add(descText);

		worldText = new FlxText(0, 200, 400, "DEBUG2", 16);
		worldText.visible = false;
		add(worldText);

		screenText = new FlxText(515, 70, 400, "Start", 16);
		screenText.setFormat(Paths.font("smwWORLDS.TTF"), 24, FlxColor.BLACK, LEFT);
		//screenText.antialiasing = false;
		add(screenText);

		introBox = new FlxSprite(0, 0);
		introBox.loadGraphic(Paths.image('warpzone/bfintro'));
		introBox.setGraphicSize(Std.int(introBox.width * 3));
		introBox.updateHitbox();
		introBox.antialiasing = false;
		introBox.screenCenter();
		introBox.y = Std.int(introBox.y);
		introBox.visible = false;
		add(introBox);

		introButton = new FlxSprite(884, 603);
		introButton.frames = Paths.getSparrowAtlas('warpzone/enter');
		introButton.animation.addByPrefix('appear', "enter appear", 12, false);
		introButton.animation.addByPrefix('press', "enter press", 12);
		introButton.animation.play('appear');
		introButton.setGraphicSize(Std.int(introButton.width * 3));
		introButton.antialiasing = false;
		introButton.visible = false;
		add(introButton);

		blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		blackScreen.alpha = 1;
		add(blackScreen);

		for (i in 0...6)
			{
				new FlxTimer().start(0.1 * i, function(tmr:FlxTimer)
					{
						blackScreen.alpha -= 0.2;
						if(i == 5){
							if(!startCut){
							quieto = true;
							}
						}
					});
				
			}

		if(startCut && !ClientPrefs.storySave[1]){
			quieto = false;
			new FlxTimer().start(1, function(tmr:FlxTimer)
				{
					FlxG.sound.play(Paths.sound('owCuts/yea'));
					bfAnim1.animation.play('idle');
				});
			new FlxTimer().start(1.7, function(tmr:FlxTimer)
				{
					pibemapa.visible = true;
					bfAnim1.visible = false;
					var boxy:Float = introBox.y;
					introBox.scale.y = 0.001;
					introBox.scale.x = 0.001;
					introBox.visible = true;
					new FlxTimer().start(0.5, function(tmr:FlxTimer)
						{
							FlxG.sound.play(Paths.sound('message'));
						});
					FlxTween.tween(introBox.scale, {y: 3, x: 3}, 0.5, {ease: FlxEase.backOut, startDelay: 0.5, onComplete: function(twn:FlxTween)
						{
							new FlxTimer().start(1, function(tmr:FlxTimer)
								{
									FlxG.sound.play(Paths.sound('owCuts/enter'));
									introButton.animation.play('appear');
									introButton.visible = true;
									canPress = true;
								});
						}
					});
				});
		}else{
			startCut = false;
			pibemapa.visible = true;
			bfAnim1.visible = false;
			FlxG.sound.playMusic(Paths.music('warpzone/0'), 0);
			FlxG.sound.music.fadeIn(1, 0, 0.5);
		}

		var lascord:Array<Float> = WarpData.getCoords(curSelected, 0);
		pibemapa.x = lascord[0];
		pibemapa.y = lascord[1];
		pibemapa.animation.play('idle');
		screenText.text = canciones[curSelected][0].toUpperCase();

		vcr = new CRTShader();
		FlxG.camera.setFilters([new ShaderFilter(vcr)]);

		if(pipeCut) openSubState(new PipeState());


		// try {
		//	transition = new SMWPixelBlurShader();
		//	FlxG.camera.setFilters([new ShaderFilter(transition)]);
		//	} catch (e) {
		//	trace(e.message);
		//	}
	
	        #if android
		addVirtualPad(LEFT_RIGHT, A_B);
		addPadCamera();
		#end
	}

	var datos:String = '';
	var mov:Float = 1;

	// possible the most simple code you ever see in your life like is a ton of if/else s.

	override function update(elapsed:Float)
	{

		if (!debugmode)
		{
			if (FlxG.keys.justPressed.ONE)
			{
				thetimer = new FlxTimer().start(3, function(tmr:FlxTimer)
				{
					if (FlxG.keys.pressed.ONE)
					{
						descText.visible = true;
						worldText.visible = true;
						debugmode = true;
						FlxG.sound.playMusic(Paths.music('test'), 0.7);
						FlxG.camera.filtersEnabled = false;
					}
				});
			}
			if(FlxG.keys.justReleased.ONE){
				thetimer.cancel();
			}

			if (quieto)
			{
				if (controls.ACCEPT)
					{
						goodbye();
					}

				if (controls.UI_LEFT_P)
				{
					quieto = false;
					caminar(canciones[curSelected][3]);
				}
				else if (controls.UI_RIGHT_P)
				{
					quieto = false;
					caminar(canciones[curSelected][4]);
				}

				// NORMAL
			}
			else{
				if (controls.ACCEPT && canPress)
					{
						canPress = false;
						introButton.animation.play('press');
						FlxG.sound.play(Paths.sound('accept'));
						new FlxTimer().start(0.5, function(tmr:FlxTimer)
							{
								quieto = true;
								startCut = false;
								introButton.visible = false;
								FlxG.sound.playMusic(Paths.music('warpzone/0'), 0);
								FlxG.sound.music.fadeIn(1, 0, 0.5);
							});
						FlxTween.tween(introBox, {y: 720}, 1, {ease: FlxEase.backIn, startDelay: 0.5});
					}
			}
		}
		else
		{
			//curDeg
			var thing:FlxSprite = pibemapa;
			datos = '' + thing.x + ', ' + thing.y;
			
			#if debug
			if (FlxG.keys.justPressed.ONE)
				{
					changeWorld(0, FlxG.keys.pressed.SHIFT);
				}
			if (FlxG.keys.justPressed.TWO)
				{
					changeWorld(1, FlxG.keys.pressed.SHIFT);
				}
			if (FlxG.keys.justPressed.THREE)
				{
					changeWorld(2, FlxG.keys.pressed.SHIFT);
				}
			if (FlxG.keys.justPressed.FOUR)
				{
					changeWorld(3, FlxG.keys.pressed.SHIFT);
				}
			if (FlxG.keys.justPressed.FIVE)
				{
					changeWorld(4, FlxG.keys.pressed.SHIFT);
				}
			if (FlxG.keys.justPressed.SIX)
				{
					ClientPrefs.deathIHY = !ClientPrefs.deathIHY;
				}
			#end


			if (FlxG.keys.pressed.ENTER)
			{
				Clipboard.generalClipboard.setData(TEXT_FORMAT, datos, true);

				var savetext = new FlxText(0, 500, 0, "coordenadas guardadas!", 16);
				add(savetext);

				FlxTween.tween(savetext, {alpha: 0}, 2, {
					startDelay: 1,
					onComplete: function(twn:FlxTween)
					{
						savetext.destroy();
					}
				});
			}

			if (FlxG.keys.pressed.CONTROL)
			{
				mov = 10;
			}
			else
			{
				mov = 1;
			}

			if (!FlxG.keys.pressed.SHIFT)
			{
				descText.text = 'MUNDOS:\nW1:' + ClientPrefs.worlds[0] + '\nW2:' + ClientPrefs.worlds[1] + '\nW3:' + ClientPrefs.worlds[2] + '\nW4:' + ClientPrefs.worlds[3] + '\nW5:' + ClientPrefs.worlds[4];
				if (FlxG.keys.pressed.UP)
				{
					thing.y -= mov;
				}
				else if (FlxG.keys.pressed.DOWN)
				{
					thing.y += mov;
				}

				if (FlxG.keys.pressed.LEFT)
				{
					thing.x -= mov;
				}
				else if (FlxG.keys.pressed.RIGHT)
				{
					thing.x += mov;
				}
			}
			else
			{
				worldText.text = 'MUNDOS:\nW1:' + ClientPrefs.worldsALT[0] + '\nW2:' + ClientPrefs.worldsALT[1] + '\nW3:' + ClientPrefs.worldsALT[2] + '\nW4:' + ClientPrefs.worldsALT[3] + '\nW5:' + ClientPrefs.worldsALT[4];
				if (FlxG.keys.justPressed.UP)
				{
					thing.y -= mov;
				}
				else if (FlxG.keys.justPressed.DOWN)
				{
					thing.y += mov;
				}

				if (FlxG.keys.justPressed.LEFT)
				{
					thing.x -= mov;
				}
				else if (FlxG.keys.justPressed.RIGHT)
				{
					thing.x += mov;
				}
			}
		}

		if (FlxG.keys.justPressed.Q){
			if(curDeg == 5){
				curDeg = 0;
			}else{
				curDeg++;
			}
		}

		if (controls.BACK)
		{
			ClientPrefs.saveSettings();
			PlayState.isWarp = false;
			FlxG.sound.music.stop();
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new MainMenuState());
		}

		#if debug
		if (FlxG.keys.justPressed.NINE) {
		openSubState(new UltraState());
		}
		#end

		super.update(elapsed);
	}

	function changeWorld(world:Int, ifshift:Bool){
		var limits:Array<Int> = [3, 7, 5, 6, 3];
		var limitsALT:Array<Int> = [5, 5, 5, 5, 5];

		if(!ifshift){
		if(ClientPrefs.worlds[world] < limits[world]){
			ClientPrefs.worlds[world]++;
		}else{
			ClientPrefs.worlds[world] = 0;
		}
		}else{
			if(ClientPrefs.worldsALT[world] < limitsALT[world]){
				ClientPrefs.worldsALT[world]++;
			}else{
				ClientPrefs.worldsALT[world] = 0;
			}
		}
	}

	function goodbye(){
		var canGo:Bool = false;
		if(curSelected != 1){

			if(canciones[curSelected][0] != 'Start'){
			if(ClientPrefs.worlds[(curSelected - 2)] >= starNeed[(curSelected - 2)]){
				canGo = true;
			}
			}else{
			if(ClientPrefs.storySave[6]){
				canGo = true;
			}
			}
		}else{
			canGo = true;
		}

		if(canGo){
			if(canciones[curSelected][0] != 'Start'){
				var fnaf:Float = pibemapa.y;
				quieto = false;
				pibemapa.animation.play('warp');
				FlxG.sound.play(Paths.sound('owCuts/smw_feather_get'));
				FlxTween.tween(pibemapa, {y: 0}, 0.5, {startDelay: 0.5, ease: FlxEase.quadIn});
				new FlxTimer().start(2, function(tmr:FlxTimer)
				{
					FlxG.sound.music.fadeOut(0.5, 0);
					for (i in 0...6)
						{
							new FlxTimer().start(0.1 * i, function(tmr:FlxTimer)
								{
									if(i == 5){
										LoadingState.loadAndSwitchState(new WorldState());
										pibemapa.y = fnaf;
										pibemapa.animation.play('idle');
										quieto = true;
									}
									blackScreen.alpha += 0.2;
								});
							
						}
				});
			}else{
				if(!ClientPrefs.storySave[7] && ClientPrefs.storySave[6]){
				quieto = false;
				FlxG.sound.music.fadeOut(0.5, 0);
				for (i in 0...6)
					{
				new FlxTimer().start(0.1 * i, function(tmr:FlxTimer)
					{
						if(i == 5){
							new FlxTimer().start(1, function(tmr:FlxTimer)
								{
							openSubState(new UltraState());
								});
							pibemapa.animation.play('idle');
							quieto = true;
						}
						blackScreen.alpha += 0.2;
					});
					};
				}
			}
		}else{
			FlxG.sound.play(Paths.sound('wrong'));
		}
	}

	public function caminar(direction:String):Void
	{
		trace(direction);
		if(direction != 'X'){
		var dir:Int = Std.parseInt(direction);
		quieto = false;
		curSelected = dir;
		WarpData.animStart(curSelected, 0, 0, pibemapa, true);
		var lascord:Array<Float> = WarpData.getCoords(curSelected, 0);

		//pibeTween = losTweens[0];

		if (pibemapa.x >= lascord[0]){
			pibemapa.animation.play('left');
		}
		else{
			pibemapa.animation.play('right');
		}
		
		new FlxTimer().start(0.8, function(tmr:FlxTimer)
		{
			if(curSelected >= 2){
				if(ClientPrefs.worlds[(curSelected - 2)] >= starNeed[(curSelected - 2)]){
					screenText.text = canciones[curSelected][0].toUpperCase();
				}else{
					screenText.text = '?????';
				}
			}else{
				screenText.text = canciones[curSelected][0].toUpperCase();
			}
			FlxG.sound.play(Paths.sound('owCuts/wz_move'));
			pibemapa.animation.play('idle');
			quieto = true;
		});
		}else{
			quieto = true;
		}
	}

	/*
		NAME	X  	Y
		0	: 403, 263
		1	: 496, 263
		2	: 592, 263
		3	: 688, 263
		4	: 784, 263
		5	: 880, 263
	 */

}
