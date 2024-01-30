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

class VirtualState extends MusicBeatSubstate
{
	var warning:FlxSprite;
	var selected:Bool = true;

	override function create() {
		FlxG.sound.music.stop();
		WarpState.pipeCut = false;
		FlxG.camera.filtersEnabled = false;
		FlxG.camera.scroll.y = 0;
		FlxG.camera.scroll.x = 0;

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);

		warning = new FlxSprite();
		warning.loadGraphic(Paths.image('warpzone/warning'));
		warning.antialiasing = false;
		warning.scale.set(0.9, 0.9);
		warning.scrollFactor.set(0,0);
		warning.updateHitbox();
		warning.screenCenter();
		warning.alpha = 0;
		//warning.x -= 180;
		add(warning);

		new FlxTimer().start(40, function(tmr:FlxTimer)
			{
				FlxG.sound.play(Paths.sound('owCuts/virtualmomo'), 0.4);
			});

		for (i in 0...6)
			{
				new FlxTimer().start(0.1 * i, function(tmr:FlxTimer)
					{
						warning.alpha += 0.2;
						if(warning.alpha == 1){
							selected = false;
						}
					});
			}
	}

	override function update(elapsed:Float) {
		if (FlxG.mouse.justReleased && !selected){
			selected = true;

			for (i in 0...6)
				{
					new FlxTimer().start(0.1 * i, function(tmr:FlxTimer)
						{
							warning.alpha -= 0.2;
							if(warning.alpha == 0){
								FlxG.camera.visible = false;
								LoadingState.loadAndSwitchState(new PlayState());
							}
						});
				}
		}
	}
}