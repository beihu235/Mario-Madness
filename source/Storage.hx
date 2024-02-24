package;

import haxe.io.Path;
import haxe.Exception;
import lime.utils.Assets;
import openfl.system.System;
#if sys
import sys.FileSystem;
import sys.io.File;
#end

#if android
import android.content.Context;
import android.os.Build;
#end

using StringTools;

class Storage
{
	public static function copyNecessaryFiles():Void
	{	 
	    FileSystem.createDirectory(Context.getExternalFilesDir());  //修下后续逻辑漏洞   	    
		#if VIDEOS_ALLOWED
		for (file in Assets.list().filter(folder -> folder.startsWith('assets/videos')))
		{
			if (Path.extension(file) == 'mp4')
			{
				// Ment for FNF's libraries system...
				final shit:String = file.replace(file.substring(0, file.indexOf('/', 0) + 1), '');
				final library:String = shit.replace(shit.substring(shit.indexOf('/', 0), shit.length), '');

				@:privateAccess
				Storage.copyFile(Assets.libraryPaths.exists(library) ? '$library:$file' : file, file);
			}
		}
		#end
		
	        #if LUA_ALLOWED
		for (dir in ['characters'])
		{
			for (file in Assets.list().filter(folder -> folder.startsWith('mods/$dir')))
			{
				if (Path.extension(file) == 'lua' || (dir == 'custom_events' && Path.extension(file) == 'txt'))
				{
					// Ment for FNF's libraries system...
					final shit:String = file.replace(file.substring(0, file.indexOf('/', 0) + 1), '');
					final library:String = shit.replace(shit.substring(shit.indexOf('/', 0), shit.length), '');

					@:privateAccess
					Storage.copyFile(Assets.libraryPaths.exists(library) ? '$library:$file' : file, file);
				}
			}
		}
		
		#end

		System.gc();
	}

	/**
	 * This is mostly a fork of https://github.com/openfl/hxp/blob/master/src/hxp/System.hx#L595
	 */
	public static function mkDirs(directory:String):Void
	{
		var total:String = '';

		if (directory.substr(0, 1) == '/')
			total = '/';

		final parts:Array<String> = directory.split('/');

		if (parts.length > 0 && parts[0].indexOf(':') > -1)
			parts.shift();

		for (part in parts)
		{
			if (part != '.' && part.length > 0)
			{
				if (total != '/' && total.length > 0)
					total += '/';

				total += part;

				if (!FileSystem.exists(Context.getExternalFilesDir() + '/' + total))
					FileSystem.createDirectory(Context.getExternalFilesDir() + '/' + total);
			}
		}
	}

	public static function copyFile(copyPath:String, savePath:String):Void
	{
		try
		{
			if (!FileSystem.exists(Context.getExternalFilesDir() + '/' + savePath) && Assets.exists(copyPath))
			{
				if (!FileSystem.exists(Context.getExternalFilesDir() + '/' + Path.directory(savePath)))
					Storage.mkDirs(Path.directory(savePath));

				File.saveBytes(Context.getExternalFilesDir() + '/' + savePath, Assets.getBytes(copyPath));
			}
		}
		catch (e:Exception)
			trace(e.message);
	}
}
