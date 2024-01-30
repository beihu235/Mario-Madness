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

class WorldState extends MusicBeatState
{

	var tween:FlxTween;
	var tween2:FlxTween;
	var thetimer:FlxTimer;
	var pipeTimer:Float;
	var curSelected:Int = 0;
	var world:Int = 0;
	var debugmode:Bool = false;
	var bfprefix:String = '';
	var effect:SMWPixelBlurShader;
	
	private static var canciones:Array<Dynamic> = [
		// Name, 			UP, DOWN, LEFT, RIGHT
		['Start', 			'X', 'X', 'X', '1', 0],
		['Alone', 			'2', '4', '0', 'X', 0],
		['Oh God No', 		'3', '4', '1', 'X', 0],
		['I Hate You', 		'X', '2', 'X', 'X', 0],
		['Thalassophobia', 	'2', '5', '1', 'X', 0],
		['Apparition', 		'X', 'X', '4', '6', 0],
		['Last Course', 	'7', '5', 'X', 'X', 0],
		['Dark Forest', 	'X', '6', 'X', 'X', 0]
	];

	private static var posmierda:Array<Dynamic> = [ //la posicion en el mismo orden que las canciones esas bien mierda
		// ICON, 	 X, Y,
		['star', 	345, 356],
		['dot', 	450, 363],
		['none', 	0, 0],
		['castle', 	588, 158],
		['dot', 	593, 463],
		['dot', 	711, 540],
		['dot', 	798, 393],
		['big', 	794, 241]
	];

	var bg:FlxSprite;
	var bgworld1:FlxSprite;
	var bgworld2:FlxSprite;
	var bgworld3:FlxSprite;
	var bgworld4:FlxSprite;
	var bgpath:FlxSprite;
	var pibemapa:FlxSprite;
	var pibeback:FlxSprite;
	var bgWarps:FlxSprite;
	var gameLives:FlxSprite;
	var thesmoke:FlxSprite;
	var descText:FlxText;
	var screenText:FlxText;
	var worldDots:FlxTypedSpriteGroup<FlxSprite>;
	var smokeGroup:FlxTypedSpriteGroup<FlxSprite>;
	var blackScreen:FlxSprite;
	var blackBar0:FlxSprite;
	var blackBar1:FlxSprite;
	var blackBG:FlxSprite;
	var boringthunder:FlxSprite;
	var bowser:FlxSprite;
	var thunderTimer:Float = 0;

	var gbSpr0:FlxSprite;
	var gbSpr1:FlxSprite;

	public var camWorld:FlxCamera;
	var camFollow:FlxObject;

	public var vcr:CRTShader;

	override function create() {

		canciones = WarpData.getWorld(WarpState.curSelected);
		posmierda = WarpData.getPos(WarpState.curSelected);

		camWorld = new FlxCamera();
		FlxG.cameras.reset(camWorld);
		FlxCamera.defaultCameras = [camWorld];

		blackBG = new FlxSprite().makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		add(blackBG);

		boringthunder = new FlxSprite().makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.WHITE);
		boringthunder.alpha = 0;
		add(boringthunder);

		if(WarpState.curSelected == 5){
			thunderTimer = FlxG.random.int(10, 30);
			bowser = new FlxSprite(860, 67);
			bowser.loadGraphic(Paths.image('warpzone/5/bose'));
			bowser.setGraphicSize(Std.int(bowser.width * 3));
			bowser.antialiasing = false;
			add(bowser);
			FlxTween.tween(bowser, {y: 110}, 1.5, {ease: FlxEase.sineInOut, type: FlxTweenType.PINGPONG});

			FlxTween.tween(bowser, {x: 440}, 4, {ease: FlxEase.sineInOut, type: FlxTweenType.PINGPONG, onComplete: function(twn:FlxTween)
				{
					bowser.flipX = !bowser.flipX;
				}});
		} 

		if(WarpState.curSelected != 3){
			bgworld1 = new FlxSprite(0, 10);
			bgworld1.loadGraphic(Paths.image('warpzone/' + WarpState.curSelected + '/bg1'));
			bgworld1.setGraphicSize(Std.int(bgworld1.width * 3));
			bgworld1.antialiasing = false;
			bgworld1.screenCenter();
			bgworld1.y -= 11;
			add(bgworld1);
		}else{
			bgworld1 = new FlxSprite(0, 10);
			bgworld1.frames = Paths.getSparrowAtlas('warpzone/' + WarpState.curSelected + '/bg1');
			bgworld1.setGraphicSize(Std.int(bgworld1.width * 3));
			bgworld1.animation.addByPrefix('idle', "idle", 6);
			bgworld1.animation.play('idle');
			bgworld1.antialiasing = false;
			bgworld1.screenCenter();
			bgworld1.y -= 11;
			add(bgworld1);
		}
		if(WarpState.curSelected == 1){
			bgworld2 = new FlxSprite(0, 10);
			bgworld2.frames = Paths.getSparrowAtlas('warpzone/' + WarpState.curSelected + '/bg2');
			bgworld2.setGraphicSize(Std.int(bgworld2.width * 3));
			bgworld2.animation.addByPrefix('idle', "idle", 6, false);
			bgworld2.animation.play('idle');
			bgworld2.antialiasing = false;
			bgworld2.screenCenter();
			bgworld2.y -= 11;
			bgworld2.x -= 280;
			add(bgworld2);
		}else{
			bgworld2 = new FlxSprite(0, 10);
			bgworld2.loadGraphic(Paths.image('warpzone/' + WarpState.curSelected + '/bg2'));
			bgworld2.setGraphicSize(Std.int(bgworld2.width * 3));
			bgworld2.antialiasing = false;
			bgworld2.screenCenter();
			bgworld2.y -= 11;
			if(WarpState.curSelected == 4){
				bgworld2.x = 465;
				bgworld2.y = 97;
			}
			add(bgworld2);
		}

		var pathdata:Int = (ClientPrefs.worlds[(WarpState.curSelected - 1)] + 1);
		if(pathdata > (canciones.length - 1)) pathdata = (canciones.length - 1);

		bgpath = new FlxSprite(WarpData.pathPos(WarpState.curSelected, 'X'), WarpData.pathPos(WarpState.curSelected, 'Y'));
		bgpath.frames = Paths.getSparrowAtlas('warpzone/' + WarpState.curSelected + '/path');
		bgpath.animation.addByPrefix('1', "path 1", 6);
		bgpath.animation.addByPrefix('2', "path 2", 6);
		bgpath.animation.addByPrefix('3', "path 3", 6);
		bgpath.animation.addByPrefix('4', "path 4", 6);
		bgpath.animation.addByPrefix('5', "path 5", 6);
		bgpath.animation.addByPrefix('6', "path 6", 6);
		bgpath.animation.addByPrefix('7', "path 7", 6);
		bgpath.animation.play('' + pathdata);
		bgpath.setGraphicSize(Std.int(bgpath.width * 3));
		bgpath.antialiasing = false;
		add(bgpath);

		if(WarpState.curSelected == 4){
			gbSpr0 = new FlxSprite(602, 315);
			gbSpr0.frames = Paths.getSparrowAtlas('warpzone/4/gbaura');
			gbSpr0.animation.addByPrefix("anim", 'gbaura idle', 6, true);
			gbSpr0.animation.play("anim");
			gbSpr0.setGraphicSize(Std.int(gbSpr0.width * 3));
			gbSpr0.visible = ClientPrefs.worlds[3] >= 1;
			add(gbSpr0);

			gbSpr1 = new FlxSprite(608, 321);
			gbSpr1.frames = Paths.getSparrowAtlas('warpzone/4/gb_level');
			gbSpr1.animation.addByPrefix("anim", 'gb level idle', 6, false);
			gbSpr1.animation.play("anim");
			gbSpr1.setGraphicSize(Std.int(gbSpr1.width * 3));
			gbSpr1.visible = ClientPrefs.worlds[3] >= 1;
			add(gbSpr1);

		}

		worldDots = new FlxTypedSpriteGroup<FlxSprite>();
		for (i in 0...canciones.length)
		{
			var place:String = posmierda[i][0];
			var theanim:String = 'idle';
			if(posmierda[i][0] == 'none') place = 'dot';
			var dot:FlxSprite = new FlxSprite(posmierda[i][1], posmierda[i][2]);
			dot.frames = Paths.getSparrowAtlas('warpzone/' + place);
			dot.antialiasing = false;
			dot.setGraphicSize(Std.int(dot.width * 3));
			dot.ID = i;

			if(posmierda[i][0] == 'castle' && WarpState.curSelected == 2){
				if(ClientPrefs.worldsALT[1] == 2 || ClientPrefs.worlds[1] > 2){
				theanim = 'dead';
				}
			}
			if(posmierda[i][0] == 'ring'){
				dot.animation.addByPrefix("appear", 'appear', 6, false);
				dot.animation.addByPrefix("vanish", 'vanish', 24, false);
			}

			dot.animation.addByPrefix("anim", theanim, 6, true);
			dot.animation.play("anim");

			if(canciones[i][0] == "Unbeatable" && !ClientPrefs.storySave[7] && ClientPrefs.worlds[3] != 0){
				dot.alpha = 0;
			}

			if(posmierda[i][0] == 'none') dot.alpha = 0;//si lo omito entonces jode mas el contador
			if(WarpState.unlockpath){
			if(canciones[i][5] > (pathdata - 2)) dot.visible = false;
			}else{
			if(canciones[i][5] > (pathdata - 1)) dot.visible = false;
			}
			worldDots.add(dot);
		}
		add(worldDots);

		pibemapa = new FlxSprite(616, 497);
		var deadSuffix = '';
		if(ClientPrefs.storySave[7]) deadSuffix = 'dead_';
		pibemapa.frames = Paths.getSparrowAtlas('warpzone/' + deadSuffix + 'overworld_bf');

		pibemapa.animation.addByPrefix('idle', "overworld bf walk down", 6);
		pibemapa.animation.addByPrefix('up', "overworld bf walk up", 6);
		pibemapa.animation.addByPrefix('down', "overworld bf walk down", 6);
		pibemapa.animation.addByPrefix('left', "overworld bf walk left", 6);
		pibemapa.animation.addByPrefix('right', "overworld bf walk right", 6);

		pibemapa.animation.addByPrefix('Widle', "overworld bf swim down", 6);
		pibemapa.animation.addByPrefix('Wup', "overworld bf swim up", 6);
		pibemapa.animation.addByPrefix('Wdown', "overworld bf swim down", 6);
		pibemapa.animation.addByPrefix('Wleft', "overworld bf swim left", 6);
		pibemapa.animation.addByPrefix('Wright', "overworld bf swim right", 6);

		pibemapa.animation.addByPrefix('climb', "overworld bf climb", 6);
		pibemapa.animation.addByPrefix('start', "overworld bf level start", 6);
		pibemapa.animation.addByPrefix('Wstart', "overworld bf enter level swim", 6);

		pibemapa.animation.addByIndices('quiet', "overworld bf walk down", [0], "", 6);
		pibemapa.animation.addByIndices('Wquiet', "overworld bf swim down", [0], "", 6);

		pibemapa.animation.addByIndices('quietUP', "overworld bf walk up", [0], "", 6);
		pibemapa.animation.add('warp', [0, 5, 9, 13], 10);
		pibemapa.setGraphicSize(Std.int(pibemapa.width * 3));
		pibemapa.antialiasing = false;
		pibemapa.animation.play('quiet');
		pibemapa.updateHitbox();
		add(pibemapa);

		pibeback = new FlxSprite(616, 497);
		pibeback.frames = Paths.getSparrowAtlas('warpzone/bfAnims/' + deadSuffix + 'overworldreturnpipe');
		pibeback.animation.addByPrefix('intro', "overworldreturnpipe intro", 12, false);
		pibeback.animation.addByPrefix('enter', "overworldreturnpipe enter", 12, false);
		pibeback.animation.addByPrefix('cancel', "overworldreturnpipe cancel",24, false);
		pibeback.setGraphicSize(Std.int(pibeback.width * 3));
		pibeback.antialiasing = false;
		pibeback.updateHitbox();
		pibeback.animation.play('intro');
		pibeback.visible = false;
		add(pibeback);

		var pibemorph = new FlxSprite(616, 497); 
		pibemorph.frames = Paths.getSparrowAtlas('warpzone/bfAnims/morph');
		pibemorph.animation.addByPrefix('pico', "overdueoverworldmorph pico", 12, false);
		pibemorph.animation.addByPrefix('morph', "overdueoverworldmorph morph",12, false);
		pibemorph.setGraphicSize(Std.int(pibemorph.width * 3));
		pibemorph.antialiasing = false;
		pibemorph.updateHitbox();
		pibemorph.animation.play('morph');
		//pibemorph.visible = false;
		add(pibemorph);

		if(WarpState.curSelected == 2 || WarpState.curSelected == 4){
		bgworld3 = new FlxSprite(0, 10);
		bgworld3.frames = Paths.getSparrowAtlas('warpzone/' + WarpState.curSelected + '/bg3');
		bgworld3.setGraphicSize(Std.int(bgworld3.width * 3));
		bgworld3.animation.addByPrefix('idle', "idle", 6);
		bgworld3.animation.play('idle');
		bgworld3.antialiasing = false;
		bgworld3.screenCenter();
		bgworld3.y -= 11;
		add(bgworld3);
		if(WarpState.curSelected == 4){
			bgworld3.x = 524;
			bgworld3.y = 107;
		}
		}else if(WarpState.curSelected == 5){
			bgworld3 = new FlxSprite(0, 10);
			bgworld3.loadGraphic(Paths.image('warpzone/' + WarpState.curSelected + '/bg3'));
			bgworld3.setGraphicSize(Std.int(bgworld3.width * 3));
			bgworld3.antialiasing = false;
			bgworld3.screenCenter();
			bgworld3.y -= 11;
			add(bgworld3);
		}
		if(WarpState.curSelected == 2){
		bgworld4 = new FlxSprite(0, 10);
		bgworld4.loadGraphic(Paths.image('warpzone/' + WarpState.curSelected + '/bg4'));
		bgworld4.setGraphicSize(Std.int(bgworld4.width * 3));
		bgworld4.antialiasing = false;
		bgworld4.screenCenter();
		bgworld4.y -= 11;
		add(bgworld4);
		if(!ClientPrefs.deathIHY){
			bgworld2.visible = false;
			bgworld4.visible = false;
		}
		}

		thesmoke = new FlxSprite(0, 0);
		thesmoke.frames = Paths.getSparrowAtlas('warpzone/smoke_overworld');
		thesmoke.setGraphicSize(Std.int(thesmoke.width * 3));
		thesmoke.animation.addByPrefix('idle', "idle", 6, true);
		thesmoke.antialiasing = false;
		thesmoke.visible = true;
		add(thesmoke);

		gameLives = new FlxSprite(0, 0);
		gameLives.frames = Paths.getSparrowAtlas('warpzone/overworld_overlay');
		gameLives.animation.addByPrefix('idle', "overworld overlay idle", 6);
		gameLives.animation.play('idle');
		gameLives.setGraphicSize(Std.int(gameLives.width * 3));
		gameLives.antialiasing = false;
		gameLives.updateHitbox();
		gameLives.screenCenter();
		gameLives.scrollFactor.set(0, 0);
		add(gameLives);

		screenText = new FlxText(515, 70, 1280, "STAR ROAD", 16);
		screenText.setFormat(Paths.font("smwWORLDS.TTF"), 24, FlxColor.BLACK, LEFT);
		screenText.antialiasing = false;
		screenText.scrollFactor.set(0, 0);
		add(screenText);

		blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		blackScreen.alpha = 1;
		blackScreen.scrollFactor.set(0, 0);
		add(blackScreen);

		blackBar0 = new FlxSprite().makeGraphic(500, FlxG.height, FlxColor.BLACK);
		blackBar0.alpha = 1;
		blackBar0.x = -244;
		blackBar0.scrollFactor.set(0, 0);
		add(blackBar0);

		blackBar1 = new FlxSprite().makeGraphic(500, FlxG.height, FlxColor.BLACK);
		blackBar1.alpha = 1;
		blackBar1.x = 1024;
		blackBar1.scrollFactor.set(0, 0);
		add(blackBar1);

		descText = new FlxText(0, 20, 400, "DEBUG", 16);
		descText.visible = false;
		descText.scrollFactor.set(0, 0);
		add(descText);

		curSelected = WarpState.worldSelected;
		if(canciones[curSelected][5] >= ClientPrefs.worlds[(WarpState.curSelected - 1)] && canciones[curSelected][0] != 'Start'){
			screenText.text = '????';
		}else{
			screenText.text = canciones[curSelected][0].toUpperCase();
		}

		screenText.text = checkName(curSelected, screenText.text);

		var thecord:Array<Float> = WarpData.getCoords(curSelected, WarpState.curSelected);
		pibemapa.x = thecord[0];
		pibemapa.y = thecord[1];

		var extratime:Float = 0;

		if(WarpState.isPico){
			if(!WarpState.unlockpath || (ClientPrefs.worlds[(WarpState.curSelected - 1)] + 1) > canciones.length - 1){
			}else{bgpath.animation.play('' + (pathdata - 1));}

			WarpState.isPico = false;
			extratime = 2;
			pibemapa.visible = false;
			pibemorph.animation.play('pico');
			pibemorph.setPosition(pibemapa.x + 6, pibemapa.y + 27);
			pibemorph.visible = true;
			new FlxTimer().start(1, function(tmr:FlxTimer)
				{
					pibemorph.animation.play('morph');
				});
		}
			new FlxTimer().start(extratime, function(tmr:FlxTimer)
				{
					pibemapa.visible = true;
					pibemorph.visible = false;
					if(!WarpState.unlockpath || (ClientPrefs.worlds[(WarpState.curSelected - 1)] + 1) > canciones.length - 1){
						if(WarpState.curSelected == 2 && ClientPrefs.deathIHY){
							FlxG.sound.playMusic(Paths.music('warpzone/' + WarpState.curSelected + 'B'), 0);
						}else{
							FlxG.sound.playMusic(Paths.music('warpzone/' + WarpState.curSelected), 0);
						}
					FlxG.sound.music.fadeIn(1, 0, 0.5);
			
					WarpState.unlockpath = false;
					if((ClientPrefs.worlds[(WarpState.curSelected - 1)] + 1) > canciones.length - 1){
			
						ClientPrefs.worlds[(WarpState.curSelected - 1)] = canciones.length - 1;
						worldDots.forEach(function(dot:FlxSprite)
							{
			
								if (canciones[dot.ID][5] <= (pathdata - 1))
									{
										dot.visible = true;
									}
							});
					}
			
					pibemapa.animation.play(bfprefix + 'idle');
					quieto = true;
					}else{
						bgpath.animation.play('' + (pathdata - 1));
						if(pibemapa.x >= 497 && pibemapa.x <= 647 && pibemapa.y <= 451 && pibemapa.y >= 139 && WarpState.curSelected == 2){
							bfprefix = 'W';
						}
						pibemapa.animation.play(bfprefix + 'quiet');
						
						unlockSmoke(pathdata);
					}
				});

				


		effect = new SMWPixelBlurShader();
		vcr = new CRTShader();
		camWorld.setFilters([new ShaderFilter(effect.shader), new ShaderFilter(vcr)]);

		for (i in 0...5)
			{
				new FlxTimer().start(0.1 * i, function(tmr:FlxTimer)
					{
						blackScreen.alpha -= 0.2;
					});
				
			}
		super.create();
		camFollow = new FlxObject(0, 0, 1, 1);
		if(WarpState.curSelected >= 4){
			var limits = [773, 535, 425, -16];
			if(WarpState.curSelected == 5) limits = [648, 535, 548, 96];
				camFollow.x = pibemapa.x;
				camFollow.y = pibemapa.y;
				if(camFollow.x >= limits[0]) camFollow.x = limits[0];
				if(camFollow.y >= limits[1]) camFollow.y = limits[1];

				if(camFollow.x <= limits[2]) camFollow.x = limits[2];
				if(camFollow.y <= limits[3]) camFollow.y = limits[3];
				
			//camWorld.setScrollBounds(-163, null, -220, null); //for some reason set MaxScroll broke the camerA?????? FUCK THIS CODE GO TO UNITY IS WAY BETTER // nvm Unity SUCKS TOO Godot is better check abandoned 3D
			camWorld.follow(camFollow, FlxCameraFollowStyle.TOPDOWN);
			camWorld.deadzone.x += 120;
			camWorld.deadzone.height -= 100;
			camWorld.deadzone.width = 0;
		}
	}

	var quieto:Bool = false;
	var bye:Bool = false;
	var datos:String = '';
	var mov:Float = 1;
	var elbicho:Int = 1;

	//TODO:
	//Sistema de guardado
	//mostrar progreso en los caminos
	//Animación del progreso de los caminos

	override function update(elapsed:Float)
		{

			if (!debugmode)
			{	
				pibeback.setPosition(pibemapa.x + 18, pibemapa.y + 6);
					if (FlxG.keys.justPressed.ONE)
					{
						thetimer = new FlxTimer().start(3, function(tmr:FlxTimer)
						{
							if (FlxG.keys.pressed.ONE)
							{
								descText.visible = true;
								debugmode = true;
								FlxG.sound.playMusic(Paths.music('test'), 0.7);
								camWorld.filtersEnabled = false;
							}
						});
					}
					if(FlxG.keys.justReleased.ONE){
						thetimer.cancel();
					}

					if(pibeback.animation.curAnim.name != 'enter' && quieto){
					if (FlxG.keys.pressed.ESCAPE && curSelected != 0){
							if(pipeTimer == 0){
								
								pibeback.animation.play('intro');
								pibeback.visible = true;
								pibemapa.visible = false;
							}else if(pipeTimer >= 2){
								goBack();
							}
							pipeTimer += elapsed; 
					}
						else{
							if(pibeback.animation.curAnim.name != 'cancel'){
								pibeback.animation.play('cancel');
							}else{
								if(pibeback.animation.curAnim.finished){
									pibeback.visible = false;
									pibemapa.visible = true;
								}
							}
							pipeTimer = 0;
						}
					}

					if(WarpState.curSelected == 2 && !WarpState.unlockpath){
						if(pibemapa.x >= 497 && pibemapa.x <= 647 && pibemapa.y <= 451 && pibemapa.y >= 139){
							if(bfprefix == ''){
							bfprefix = 'W';
							var lol:String = pibemapa.animation.curAnim.name;
							pibemapa.animation.play(bfprefix + lol);
							}
						}else{
							if(bfprefix == 'W'){
								bfprefix = '';
								var lol:String = pibemapa.animation.curAnim.name;
								pibemapa.animation.play(lol.substr(1));
								}
						}
					}


			if(quieto && pipeTimer == 0){
				if (FlxG.keys.justPressed.UP)
				{
					caminar(canciones[curSelected][1], 1);
				}
				else if (FlxG.keys.justPressed.DOWN)
				{
					caminar(canciones[curSelected][2], 2);
				}
				else if (FlxG.keys.justPressed.LEFT)
				{
					caminar(canciones[curSelected][3], 3);
				}
				else if (FlxG.keys.justPressed.RIGHT)
				{
					caminar(canciones[curSelected][4], 4);
				}


			if (controls.ACCEPT && pipeTimer == 0)
				{
					if(canciones[curSelected][0] == 'Start'){
						quieto = false;
						bye = true;
						camWorld.target = null;
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
											WarpState.blackScreen.alpha = 1;
											if(i == 5){
												for (i in 0...6)
													{
														new FlxTimer().start(0.1 * i, function(tmr:FlxTimer)
															{
																WarpState.blackScreen.alpha -= 0.2;
															});
													}
												FlxG.sound.playMusic(Paths.music('warpzone/0'), 0);
												FlxG.sound.music.fadeIn(1, 0, 0.5);
												camWorld.scroll.y = 0;
												close();
											}else{
											blackScreen.alpha += 0.2;
											}
										});
										
									}
							});
					}
					else if(canciones[curSelected][0].toLowerCase() == "unbeatable" && !ClientPrefs.storySave[7]){
						if(ClientPrefs.worlds[3] == 0){
							quieto = false;
							FlxG.sound.play(Paths.sound('GBSpawn'));
							ClientPrefs.worlds[3] = 1;
							camWorld.shake(0.01, 0.2);
							pibemapa.animation.play("quiet");
							FlxG.sound.music.volume = 0;
							canciones[0][1] = "2";
							bgpath.animation.play("" + (ClientPrefs.worlds[(WarpState.curSelected - 1)] + 1));
							worldDots.forEach(function(dot:FlxSprite)
								{
									if (dot.ID == 1){
										dot.alpha = 0;
									}
								});
							new FlxTimer().start(2, function(tmr:FlxTimer)
								{
									pibemapa.animation.play("quietUP");
									new FlxTimer().start(1.5, function(tmr:FlxTimer){
									FlxFlicker.flicker(gbSpr0, 1, 0.2, true);

									new FlxTimer().start(2, function(tmr:FlxTimer)
										{
											gbSpr1.visible = true;
											gbSpr1.animation.play("anim");
										});
									new FlxTimer().start(4, function(tmr:FlxTimer)
										{
											worldDots.forEach(function(dot:FlxSprite)
												{
													if (dot.ID == 2){
														dot.visible = true;
													}
												});
												/*new FlxTimer().start(1.5, function(tmr:FlxTimer)
													{
														pibemapa.animation.play("quietUP");
													})*/
											pibemapa.animation.play("idle");
											quieto = true;
											gbSpr1.visible = false;
											FlxG.sound.playMusic(Paths.music('warpzone/' + WarpState.curSelected), 0);
											FlxG.sound.music.volume = 1;
										});
									});
								});
						}
								
					}
					else{
					quieto = false;
					pibemapa.animation.play(bfprefix + 'start');
					
					var thesong:String = canciones[curSelected][0].toLowerCase();
					thesong = thesong.replace(" ", "-");
					PlayState.isWarp = true;
					PlayState.isStoryMode = false;
					PauseSubState.tengo = thesong;
					PlayState.SONG = Song.loadFromJson(thesong, thesong);
					PlayState.campaignScore = 0;
					PlayState.campaignMisses = 0;

					if(WarpState.curSelected == 1 && curSelected == 3){
			
						FlxG.sound.play(Paths.sound('warpring'));
						worldDots.forEach(function(dot:FlxSprite)
							{
								if (dot.ID == 3){
									dot.animation.play('vanish');
								}
							});
						pibemapa.visible = false;
							new FlxTimer().start(1, function(tmr:FlxTimer)
							{
								FlxG.sound.music.volume = 0;
								var lightTrans:FlxSprite = new FlxSprite().makeGraphic(Std.int(gameLives.width), Std.int(gameLives.height), FlxColor.WHITE);
								lightTrans.x = gameLives.x;
								lightTrans.y = gameLives.y;
								lightTrans.alpha = 0;
								add(lightTrans);
								FlxTween.tween(lightTrans, {alpha: 1}, 0.5, {startDelay: 0.2});
								FlxG.sound.play(Paths.sound('warpring trans'));
								
								new FlxTimer().start(2, function(tmr:FlxTimer)
									{
										
										blackScreen.alpha = 1;
										WarpState.blackScreen.alpha = 1;
										lightTrans.alpha = 0;
										LoadingState.loadAndSwitchState(new PlayState());
										FlxG.sound.music.volume = 0;
									});
							});
					}else{
						for (i in 0...5)
							{
								new FlxTimer().start(0.1 * i, function(tmr:FlxTimer)
									{
										blackScreen.alpha += 0.2;
									});
								
							}
						FlxTween.tween(FlxG.sound.music, {volume: 0}, 0.7);
						FlxTween.num(SMWPixelBlurShader.DEFAULT_STRENGTH, 20, 0.7, function(v)
							{
								effect.setStrength(v, v);
							});
			
							new FlxTimer().start(1, function(tmr:FlxTimer)
							{
								WarpState.blackScreen.alpha = 1;
								FlxG.camera.visible = false;
								CustomFadeTransition.nextCamera = null;
								if(thesong == "no-party"){
									FlxG.mouse.visible = true;
									FlxG.switchState(new PartyState());
								}else if(thesong == "paranoia"){
									FlxG.camera.visible = true;
									openSubState(new VirtualState());
								}else{
									LoadingState.loadAndSwitchState(new PlayState());
								}
								FlxG.sound.music.volume = 0;
							});
					}
				}}
			}
			}else{

				if (controls.BACK)
					{
						PlayState.isWarp = false;
						FlxG.sound.music.stop();
						FlxG.sound.play(Paths.sound('cancelMenu'));
						MusicBeatState.switchState(new MainMenuState());
					}

					if (FlxG.keys.justPressed.Q)
					{
						ClientPrefs.deathIHY = false;
					}
	
				if (FlxG.keys.pressed.CONTROL)
				{
					mov = 10;
				}
				else
				{
					mov = 1;
				}

				worldDots.forEach(function(dot:FlxSprite)
					{
					if (dot.ID == elbicho)
					{
						var thing:FlxSprite = bgworld2;//Reflect.getProperty(this, 'dot'); // + elbicho
						descText.text = 'DEBUG:\nx:' + thing.x + '\ny:' + thing.y + '\nnumber:' + curSelected + '\nobject:' + elbicho;
						////descText.text = 'DEBUG:\nx:' + camFollow.x + '\ny:' + camFollow.y + '\nnumber:' + curSelected + '\nobject:' + elbicho;

						datos = '' + thing.x + ', ' + thing.y;
	
						if (FlxG.keys.justPressed.ENTER)
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
	
					if (!FlxG.keys.pressed.SHIFT)
					{
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
					if(WarpState.curSelected >= 4){
					camFollow.x = thing.x;
					camFollow.y = thing.y;
					}
					}
					});

					if (FlxG.keys.justPressed.M)
						{
							if(elbicho == worldDots.length - 1){
								elbicho = 0;
							}else{
								elbicho += 1;
							}
						}
			}
			if(WarpState.curSelected >= 4){
				if(!debugmode && !bye){
				camFollow.x = pibemapa.x;
				camFollow.y = pibemapa.y;
				}

				var limits = [773, 535, 425, -16];
				if(WarpState.curSelected == 5) limits = [648, 535, 548, 107];

				if(camFollow.x >= limits[0]) camFollow.x = limits[0];
				if(camFollow.y >= limits[1]) camFollow.y = limits[1];
				
				if(camFollow.x <= limits[2]) camFollow.x = limits[2];
				if(camFollow.y <= limits[3]) camFollow.y = limits[3];
			}

			if(thunderTimer > 0){
				thunderTimer -= elapsed;
			}else{
				thunderTimer = 10;
				if(WarpState.curSelected == 1) /*you now what that means...*/ fish()
				else if(WarpState.curSelected == 5) thunderLoop();
			}

			super.update(elapsed);
		}

		public function caminar(direction:String, anim:Int):Void
			{
				var pathdata:Int = (ClientPrefs.worlds[(WarpState.curSelected - 1)] + 1);
				if(pathdata > (canciones.length - 1)) pathdata = (canciones.length - 1);

				if(direction != 'X'){
				var lastdir:Int = curSelected;
				var thedir:Int = 0;
				thedir = Std.parseInt(direction);
				if(canciones[thedir][5] <= (pathdata - 1)){
				curSelected = thedir;
				WarpState.worldSelected = thedir;

				WarpData.animStart(thedir, lastdir, WarpState.curSelected, pibemapa, true);
				quieto = false;
				
				if(pibemapa.animation.curAnim.name == bfprefix + 'idle'){
				switch(anim){
					case 1:
						pibemapa.animation.play(bfprefix + 'up');
					case 2:
						pibemapa.animation.play(bfprefix + 'down');
					case 3:
						pibemapa.animation.play(bfprefix + 'left');
					case 4:
						pibemapa.animation.play(bfprefix + 'right');
				}
				}
		
				new FlxTimer().start(WarpState.time + 0.01, function(tmr:FlxTimer)
				{
					quieto = true;
					FlxG.sound.play(Paths.sound('owCuts/wz_move'));
					pibemapa.animation.play(bfprefix + 'idle');
					if(canciones[thedir][5] >= ClientPrefs.worlds[(WarpState.curSelected - 1)] && canciones[thedir][0] != 'Start'){
						screenText.text = '????';
					}else{
						screenText.text = canciones[thedir][0].toUpperCase();
					}
					screenText.text = checkName(thedir, screenText.text);
				});
				}
				}
			}

	function unlockSmoke(newpath:Int) {
		new FlxTimer().start(1, function(tmr:FlxTimer)
		{
			bgpath.animation.play('' + newpath);

			worldDots.forEach(function(dot:FlxSprite)
				{

					if (canciones[dot.ID][5] <= (newpath - 1))
						{
							if(WarpState.curSelected == 1 && (newpath - 1) == 2){
								new FlxTimer().start(1, function(tmr:FlxTimer)
									{
										//FlxG.sound.play(Paths.sound('owCuts/smw_boom'));
										dot.animation.play('appear');
										dot.visible = true;

										new FlxTimer().start(1.1667, function(tmr:FlxTimer)
											{
												dot.animation.play('anim');
											});
									});
							}else{
								dot.visible = true;
							}
							
						}
				});
			
			FlxG.sound.play(Paths.sound('owCuts/smw_boom'));

			var smokecords:Array<Dynamic> = WarpData.callSmoke(WarpState.curSelected, (newpath - 1));
			smokeGroup = new FlxTypedSpriteGroup<FlxSprite>();
			for (i in 0...(smokecords.length - 1))
				{
					var smoke = new FlxSprite(smokecords[0], smokecords[1]);
					smoke.frames = Paths.getSparrowAtlas('warpzone/smoke_overworld');
					smoke.setGraphicSize(Std.int(smoke.width * 3));
					smoke.animation.addByPrefix('idle', "idle", 6, false);
					smoke.antialiasing = false;
					smoke.ID = i;
	
					var smokdir:Int = smokecords[i + 1];
					if(i != 0){
					switch(smokdir){
						case 0:
						smoke.y -= 48;
						case 1:
						smoke.y += 48;
						case 2:
						smoke.x -= 48;
						case 3:
						smoke.x += 48;
	
						case 4:
						smoke.y -= 48;
						smoke.x -= 48;
						case 5:
						smoke.y -= 48;
						smoke.x += 48;
						case 6:
						smoke.y += 48;
						smoke.x -= 48;
						case 7:
						smoke.y += 48;
						smoke.x += 48;
						case 8:
						smoke.x += 624;

					}
					}
					smokecords[0] = smoke.x;
					smokecords[1] = smoke.y;
					smokeGroup.add(smoke);
					smoke.animation.play('idle');
				}
				insert(members.indexOf(thesmoke) + 1, smokeGroup);
		});
		new FlxTimer().start(1.6667, function(tmr:FlxTimer)
			{
				smokeGroup.destroy();
			});
		new FlxTimer().start(2, function(tmr:FlxTimer)
			{
				if(WarpState.curSelected == 1 && (newpath - 1) == 2){
					new FlxTimer().start(2, function(tmr:FlxTimer)
						{
							quieto = true;
							WarpState.unlockpath = false;
							pibemapa.animation.play(bfprefix + 'idle');
							FlxG.sound.playMusic(Paths.music('warpzone/' + WarpState.curSelected), 0.5);
						});
				}
				else{
				if(WarpState.curSelected == 2 && ClientPrefs.deathIHY){
					FlxG.sound.playMusic(Paths.music('warpzone/' + WarpState.curSelected + 'B'), 0.5);
				}else{
					FlxG.sound.playMusic(Paths.music('warpzone/' + WarpState.curSelected), 0.5);
				}
				quieto = true;
				WarpState.unlockpath = false;
				pibemapa.animation.play(bfprefix + 'idle');
				}
			});
	}

	function checkName(dir:Int, current:String):String {

		if(canciones[dir][0] == 'Overdue'){
			if(ClientPrefs.worldsALT[3] == 1 || ClientPrefs.worldsALT[3] == 3){
				return canciones[dir][0].toUpperCase();
			}else{
				return '????';
			}
		}

		if(canciones[dir][0] == 'No Party'){
			if(ClientPrefs.worldsALT[3] >= 2){
				return canciones[dir][0].toUpperCase();
			}else{
				return '????';
			}
		}

		if(canciones[dir][0] == 'Thalassophobia' && (ClientPrefs.worldsALT[1] == 1 || ClientPrefs.worlds[1] >= 4)){
			return canciones[dir][0].toUpperCase();
		}else if(canciones[dir][0] == 'Thalassophobia'){
			return '????';
		}

		if(canciones[dir][0] == 'I Hate You' && (ClientPrefs.worldsALT[1] == 2 || ClientPrefs.worlds[1] >= 4)){
			return canciones[dir][0].toUpperCase();
		}else if(canciones[dir][0] == 'I Hate You'){
			return '????';
		}

		if(canciones[dir][0] == 'Unbeatable' && !ClientPrefs.storySave[8]){
			return '????';
		}

		return current;
	}

	function fish(){
		var fishPos:Array<Dynamic> = [[634, 491], [874, 281], [694, 101], [454, 101], [364, 281], [334, 461]];
		var newPos:Int = FlxG.random.int(0, 6);
		var fishTimer:Float = FlxG.random.int(6, 10);

		if(bgworld2.x == fishPos[newPos].x){
			fish();
			return;
		}

		thunderTimer = fishTimer;
		if(bgworld2 != null){
		bgworld2.setPosition(fishPos[newPos][0],fishPos[newPos][1]);
		bgworld2.animation.play('idle');
		}else{
			trace('WHAT');
		}

	}

	function goBack() {
		pibeback.animation.play('enter');
		new FlxTimer().start(2, function(tmr:FlxTimer)
			{
				FlxG.sound.music.fadeOut(0.5, 0);
				for (i in 0...6)
					{
					new FlxTimer().start(0.1 * i, function(tmr:FlxTimer)
						{
							WarpState.blackScreen.alpha = 1;
							if(i == 5){
								for (i in 0...6)
									{
										new FlxTimer().start(0.1 * i, function(tmr:FlxTimer)
											{
												WarpState.blackScreen.alpha -= 0.2;
											});
									}
								FlxG.sound.playMusic(Paths.music('warpzone/0'), 0);
								FlxG.sound.music.fadeIn(1, 0, 0.5);
								camWorld.scroll.y = 0;
								camWorld.target = null;
								camWorld.scroll.y = 0;
								camWorld.scroll.x = 0;
								curSelected = 0;
								WarpState.worldSelected = 0;
								close();
							}else{
							blackScreen.alpha += 0.2;
							}
						});
					}
			});
	}

	function thunderLoop() {
				thunderTimer = FlxG.random.int(10, 30);
				boringthunder.alpha = 1;
				FlxG.sound.play(Paths.sound('owCuts/smw_thunder1'));
				for (i in 0...11){
					new FlxTimer().start(i * 0.2, function(tmr:FlxTimer)
						{
							boringthunder.alpha = 1 - (i * 0.1);
						});
				}
	}
}