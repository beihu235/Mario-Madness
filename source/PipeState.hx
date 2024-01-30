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

class PipeState extends MusicBeatSubstate
{
	var pipe:FlxSprite;

	override function create() {
		FlxG.sound.music.stop();
		WarpState.pipeCut = false;
		WarpState.worldSelected = 0;
		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);

		pipe = new FlxSprite();
		pipe.loadGraphic(Paths.image('warpzone/pipeCUT'));
		pipe.antialiasing = false;
		pipe.screenCenter();
		pipe.scale.set(0.85, 0.85);
		pipe.visible = false;
		add(pipe);


		new FlxTimer().start(2, function(tmr:FlxTimer)
			{
				FlxG.sound.play(Paths.sound('owCuts/enter_the_pipe'));
				pipe.visible = true;
				for (i in 0...13){
					new FlxTimer().start(0.2 * i, function(tmr:FlxTimer)
						{
							FlxG.camera.shake(0.0002 * i, 0.2);
						});
				}
			});

			FlxTween.tween(pipe.scale, {y: 1.3, x: 1.3}, 3, {startDelay: 1.5, ease: FlxEase.expoIn, onComplete: function(twn:FlxTween)
				{
					pipe.visible = false;
					new FlxTimer().start(2, function(tmr:FlxTimer)
						{
							FlxG.sound.music.fadeOut(0.5, 0);
							WarpState.blackScreen.alpha = 1;
							for (i in 0...6)
								{
									new FlxTimer().start(0.1 * i, function(tmr:FlxTimer)
										{
											WarpState.blackScreen.alpha -= 0.2;
										});
								}
							FlxG.sound.playMusic(Paths.music('warpzone/0'), 0);
							FlxG.sound.music.fadeIn(1, 0, 0.5);
							close();
						});
				}});
	}
}