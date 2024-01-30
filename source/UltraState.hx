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

class UltraState extends MusicBeatSubstate
{
	var tween:FlxTween;
	var tween2:FlxTween;
	var thetimer:FlxTimer;
	var debugmode:Bool = false;

	var bg0:FlxSprite;
	var bgworld1:FlxSprite;
	var bgworld2:FlxTypedSpriteGroup<FlxSprite>;
	var bgworld3:FlxSprite;

	var pibemapa:FlxSprite;
	var bfAnim1:FlxSprite;
	var bfAnim2:FlxSprite;
	var screenText:FlxText;
	var blackScreen:FlxSprite;
	var quieto:Bool = false;
	var cutScenes:Int = 0;
	public var camWorld:FlxCamera;
	var camFollow:FlxObject;
	var fire:FlxSound;
	

	var effect:SMWPixelBlurShader;
	public var vcr:CRTShader;

	final info:Array<String> = ['all-stars', 'none', '0', '0'];

	override function create() {

		camWorld = new FlxCamera();
		FlxG.cameras.reset(camWorld);

		bg0 = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg0.setGraphicSize(Std.int(bg0.width * 5));
		bg0.scrollFactor.set(0, 0);
		bg0.alpha = 1;
		add(bg0);


		bgworld1 = new FlxSprite(0, 10);
		bgworld1.loadGraphic(Paths.image('warpzone/6/0'));
		bgworld1.setGraphicSize(Std.int(bgworld1.width * 3));
		bgworld1.antialiasing = false;
		bgworld1.screenCenter();
		add(bgworld1);

		bgworld2 = new FlxTypedSpriteGroup<FlxSprite>();
		for(i in 0...3){
			var bgworldPipe:FlxSprite = new FlxSprite(250, -2926);
			bgworldPipe.loadGraphic(Paths.image('warpzone/6/1'));
			bgworldPipe.setGraphicSize(Std.int(bgworldPipe.width * 3));
			bgworldPipe.updateHitbox();
			bgworldPipe.antialiasing = false;
			bgworldPipe.y += bgworldPipe.height * i;
			bgworldPipe.ID = i;
			//if(i == 3) bgworldPipe.height = Std.int(bgworldPipe.height / 2);
			//bgworldPipe.visible = bgworldPipe.ID <= 1;
			bgworld2.add(bgworldPipe);
		}
		add(bgworld2);

		bgworld3 = new FlxSprite(575, -309);
		bgworld3.frames = Paths.getSparrowAtlas('warpzone/6/leveleye');
		bgworld3.animation.addByPrefix('idle', "leveleye idle", 12, true);
		bgworld3.animation.play('idle');
		bgworld3.setGraphicSize(Std.int(bgworld3.width * 3));
		bgworld3.antialiasing = false;
		add(bgworld3);

		pibemapa = new FlxSprite(598, 824);
		pibemapa.frames = Paths.getSparrowAtlas('warpzone/overworld_bf');

		pibemapa.animation.addByPrefix('idle', "overworld bf walk down", 6);
		pibemapa.animation.addByPrefix('up', "overworld bf walk up", 6);
		pibemapa.animation.addByPrefix('down', "overworld bf walk down", 6);
		pibemapa.animation.addByPrefix('start', "overworld bf level start", 6);
		pibemapa.animation.addByPrefix('Wstart', "overworld bf enter level swim", 6);

		pibemapa.animation.addByIndices('quiet', "overworld bf walk down", [0], "", 6);
		pibemapa.animation.addByIndices('Wquiet', "overworld bf swim down", [0], "", 6);

		pibemapa.animation.addByIndices('quietUP', "overworld bf walk up", [0], "", 6);
		pibemapa.animation.add('warp', [0, 5, 9, 13], 10);
		pibemapa.setGraphicSize(Std.int(pibemapa.width * 3));
		pibemapa.antialiasing = false;
		pibemapa.updateHitbox();
		pibemapa.alpha = 0;
		//pibemapa.velocity.y = 0.00001;
		add(pibemapa);

		var pipe:FlxSprite = new FlxSprite(635, 924).loadGraphic(Paths.image('warpzone/bfAnims/pipe'));
		pipe.setGraphicSize(Std.int(pipe.width * 3));
		pipe.antialiasing = false;
		add(pipe);

		bfAnim1 = new FlxSprite(586, 833);
		bfAnim1.frames = Paths.getSparrowAtlas('warpzone/bfAnims/ultrapipeout');
		bfAnim1.animation.addByIndices('idle', "ultrapipeout out", [0], "", 6);
		bfAnim1.animation.addByPrefix('out', "ultrapipeout out", 10, false);
		bfAnim1.animation.addByPrefix('glitch', "ultrapipeout scary", 10, false);
		bfAnim1.animation.addByPrefix('calm', "ultrapipeout phew", 10, false);
		bfAnim1.animation.addByPrefix('look', "ultrapipeout look", 10, false);
		bfAnim1.animation.addByPrefix('nod', "ultrapipeout nod", 10, false);
		bfAnim1.animation.play('nod');
		bfAnim1.setGraphicSize(Std.int(bfAnim1.width * 3));
		bfAnim1.antialiasing = false;
		bfAnim1.updateHitbox();
		bfAnim1.visible = false;
		add(bfAnim1);

		bfAnim2 = new FlxSprite(568, -315);
		bfAnim2.frames = Paths.getSparrowAtlas('warpzone/bfAnims/ultralevelstart');
		bfAnim2.animation.addByPrefix('stand', "ultralevelstart stand", 10, false);
		bfAnim2.animation.addByPrefix('appear', "ultralevelstart appear", 10, false);
		bfAnim2.animation.addByPrefix('gf', "ultralevelstart gfraisemic", 10, false);
		bfAnim2.animation.addByPrefix('nod', "ultralevelstart bfnod", 10, false);
		bfAnim2.animation.addByPrefix('go', "ultralevelstart LETSFUCKINGDOTHIS GLORIA MESSI", 10, false);
		bfAnim2.animation.play('stand');
		bfAnim2.setGraphicSize(Std.int(bfAnim2.width * 3));
		bfAnim2.antialiasing = false;
		bfAnim2.updateHitbox();
		bfAnim2.visible = false;
		add(bfAnim2);

		var gameLives:FlxSprite = new FlxSprite(0, 0);
		gameLives.frames = Paths.getSparrowAtlas('warpzone/overworld_overlay');
		gameLives.animation.addByPrefix('idle', "overworld overlay idle", 6);
		gameLives.animation.play('idle');
		gameLives.setGraphicSize(Std.int(gameLives.width * 3));
		gameLives.scrollFactor.set(0, 0);
		gameLives.antialiasing = false;
		gameLives.updateHitbox();
		gameLives.screenCenter();
		add(gameLives);

		screenText = new FlxText(515, 70, 1280, "...", 16);
		screenText.setFormat(Paths.font("smwWORLDS.TTF"), 24, FlxColor.BLACK, LEFT);
		screenText.antialiasing = false;
		screenText.scrollFactor.set(0, 0);
		add(screenText);

		blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		blackScreen.alpha = 1;
		blackScreen.scrollFactor.set(0, 0);
		add(blackScreen);

		var blackBar0:FlxSprite = new FlxSprite().makeGraphic(500, FlxG.height, FlxColor.BLACK);
		blackBar0.alpha = 1;
		blackBar0.scrollFactor.set(0, 0);
		blackBar0.x = -244;
		add(blackBar0);

		var blackBar1:FlxSprite = new FlxSprite().makeGraphic(500, FlxG.height, FlxColor.BLACK);
		blackBar1.alpha = 1;
		blackBar1.scrollFactor.set(0, 0);
		blackBar1.x = 1024;
		add(blackBar1);

		effect = new SMWPixelBlurShader();
		vcr = new CRTShader();
		camWorld.setFilters([new ShaderFilter(effect.shader), new ShaderFilter(vcr)]);
		camFollow = new FlxObject(0, 0, 1, 1);
		camWorld.follow(camFollow, FlxCameraFollowStyle.LOCKON);
		camWorld.deadzone.x -= 45;

		fire = new FlxSound().loadEmbedded(Paths.sound('fire_portal'));
		fire.volume = 0;
		fire.looped = true;
		fire.play();

		for (i in 0...5)
			{
				new FlxTimer().start(0.1 * i, function(tmr:FlxTimer)
					{
						blackScreen.alpha -= 0.2;
					});
				
			}

		new FlxTimer().start(2, function(tmr:FlxTimer)
			{
				FlxG.sound.play(Paths.sound('owCuts/ultracut1'));
				bfAnim1.visible = true;
				bfAnim1.animation.play('out');
				pipe.visible = false;

				new FlxTimer().start(1.2, function(tmr:FlxTimer)
					{
						bfAnim1.animation.play('glitch');
						new FlxTimer().start(2, function(tmr:FlxTimer)
							{
								bfAnim1.animation.play('calm');
								new FlxTimer().start(1.5, function(tmr:FlxTimer)
									{
										bfAnim1.animation.play('look');
										new FlxTimer().start(1, function(tmr:FlxTimer)
											{
												bfAnim1.animation.play('nod');
												new FlxTimer().start(2, function(tmr:FlxTimer)
													{
														bfAnim1.visible = false;
														pibemapa.alpha = 1;
														quieto = true;
													});
											});
									});
							});
					});
			});

		//pibemapa.alpha = 1;
		//quieto = true;

		//camWorld.zoom = 0.3333;
	}
	var mov:Float = 1;
	var datos:String = '';
	override function update(elapsed:Float) {
		if (!debugmode)
			{
				#if debug
				if (FlxG.keys.justPressed.ONE)
				{
					thetimer = new FlxTimer().start(3, function(tmr:FlxTimer)
					{
						if (FlxG.keys.pressed.ONE)
						{
							//descText.visible = true;
							//worldText.visible = true;
							debugmode = true;
							FlxG.sound.playMusic(Paths.music('test'), 0.7);
							FlxG.camera.filtersEnabled = false;
						}
					});
				}
				if(FlxG.keys.justReleased.ONE){
					thetimer.cancel();
				}

				
				if (FlxG.keys.justPressed.TWO)
					{
						gotoSong();
					}
				#end
				if (quieto)
				{
					if (controls.ACCEPT && cutScenes == 2)
						{
							cutScenes = 3;
							gotoSong();
						}

					if (FlxG.keys.justPressed.UP && cutScenes == 0)
						{
							quieto = false;
							caminar();
						}
	
					// NORMAL
				}
				camFollow.x = pibemapa.x;
				camFollow.y = pibemapa.y;
			}
			else
			{
				var thing:FlxSprite = Reflect.getProperty(this, 'bfAnim2');
				//descText.text = 'DEBUG:\nx:' + pibemapa.x + '\ny:' + pibemapa.y + '\nsong:' + whatsong + '\nnumber:' + curSelected;
				datos = '' + thing.x + ', ' + thing.y;
	
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

				if (controls.BACK)
					{
						ClientPrefs.saveSettings();
						PlayState.isWarp = false;
						FlxG.sound.music.stop();
						FlxG.sound.play(Paths.sound('cancelMenu'));
						MusicBeatState.switchState(new MainMenuState());
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
				camFollow.x = thing.x;
				camFollow.y = thing.y;
			}
			super.update(elapsed);
			if (!debugmode && quieto)
			{


			}

			if(pibemapa.y <= -345 && cutScenes == 1){
				pibemapa.y = -345;
				pibemapa.velocity.y = 0;
				pibemapa.animation.play('idle');
				cutScenes = 2;
				quieto = true;
			}

			if(cutScenes == 0){
			bgworld2.forEach(function(pipe:FlxSprite)
				{
					if(pipe.ID == 0 && pipe.y >= (-826 + 945)){
						bgworld2.forEach(function(thepipe:FlxSprite)
							{
								thepipe.y = -826 + (thepipe.ID * thepipe.height);
							});
					}
				});
			}else if(cutScenes == 1){
				bgworld2.forEach(function(pipe:FlxSprite)
					{
						if(pipe.ID == 0 && pipe.y >= (-826 + 945)){
							bgworld2.forEach(function(thepipe:FlxSprite)
								{
									thepipe.velocity.y = 0;
								});
							pibemapa.velocity.y = -100;
						}
					});
			}
	}

	public function caminar(){
		pibemapa.velocity.y -= 100;
		pibemapa.animation.play('up');
		new FlxTimer().start(2, function(tmr:FlxTimer)
			{
				pibemapa.velocity.y = 0;
				new FlxTimer().start(1, function(tmr:FlxTimer)
					{
						FlxG.sound.play(Paths.sound('owCuts/ultracut'));
						ultraText(0);
					});
			});
	}

	function ultraText(curLine:Int){
		var theTime:Float = 0;
		var curText:Array<Dynamic> = WarpData.script[curLine];
		theTime = curText[1];
		if(curLine != 0){
		var lastText:Array<Dynamic> = WarpData.script[curLine - 1];
		theTime -= lastText[1];
		}

		new FlxTimer().start(theTime, function(tmr:FlxTimer)
			{
				screenText.text = curText[0];
				if(curLine == 24){
					bgworld2.forEach(function(pipe:FlxSprite)
						{
							pipe.velocity.y = 100;
						});
				}
				if(curLine == WarpData.script.length - 7){
					cutScenes = 1;
					FlxTween.tween(fire, {volume: 1}, 6, {startDelay: 2});
					FlxTween.tween(camWorld.deadzone, {y: camWorld.deadzone.y - 60}, 4, {startDelay: 1});
					bgworld2.forEach(function(thepipe:FlxSprite)
						{
							thepipe.y += 945;
						});
				}
				if(curLine < WarpData.script.length - 1){
					curLine++;
					//trace('line ' + curLine + ' ends in ' + WarpData.script.length, WarpData.script[curLine].length);
					ultraText(curLine);
				} 
			});
	}

	function gotoSong() {
		pibemapa.visible = false;
		bfAnim2.visible = true;
		camWorld.shake(0.008, 0.5);
		FlxG.sound.play(Paths.sound('owCuts/ultracut2'));
		new FlxTimer().start(0.5, function(tmr:FlxTimer)
			{
				camWorld.shake(0.003, 0.5);
				new FlxTimer().start(0.5, function(tmr:FlxTimer)
					{
						camWorld.shake(0.001, 0.5);
					});
			});
			new FlxTimer().start(3, function(tmr:FlxTimer)
				{
					bfAnim2.animation.play('appear');
				});
		new FlxTimer().start(4.5, function(tmr:FlxTimer)
			{
				bfAnim2.animation.play('gf');

				new FlxTimer().start(1.2, function(tmr:FlxTimer)
					{
						bfAnim2.animation.play('nod');
						new FlxTimer().start(1.5, function(tmr:FlxTimer)
							{
								bfAnim2.animation.play('go');
								new FlxTimer().start(2, function(tmr:FlxTimer)
									{
										var thesong:String = 'All Stars';
										thesong = thesong.replace(" ", "-");
										PlayState.isWarp = true;
										PlayState.isStoryMode = false;
										PauseSubState.tengo = 'all-stars';
										PlayState.SONG = Song.loadFromJson(thesong, thesong);
										PlayState.campaignScore = 0;
										PlayState.campaignMisses = 0;

										for (i in 0...5)
											{
												new FlxTimer().start(0.1 * i, function(tmr:FlxTimer)
													{
														blackScreen.alpha += 0.2;
													});
												
											}
										FlxTween.tween(FlxG.sound.music, {volume: 0}, 0.7);
										FlxTween.tween(fire, {volume: 0}, 0.7);
										FlxTween.num(SMWPixelBlurShader.DEFAULT_STRENGTH, 20, 0.7, function(v)
											{
												effect.setStrength(v, v);
											});
							
											new FlxTimer().start(5, function(tmr:FlxTimer)
											{
												WarpState.blackScreen.alpha = 1;
												FlxG.camera.visible = false;
												CustomFadeTransition.nextCamera = null;
												LoadingState.loadAndSwitchState(new PlayState());
												FlxG.sound.music.volume = 0;
											});
									});
							});
					});
			});
	}
}