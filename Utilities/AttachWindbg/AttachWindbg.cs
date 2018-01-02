using System;
using System.Text;
using System.Diagnostics;
using InnerSpaceAPI;

namespace AttachWindbg
{
	class Program
	{
		static void Main(string[] args)
		{
			if (args == null || args.Length == 0)
			{
				InnerSpace.Echo(" ");
				InnerSpace.Echo("AttachWindbg v1 by CyberTech");
				InnerSpace.Echo(" Description:");
				InnerSpace.Echo("    Attaches windbg to a launched process immediately after Inner Space");
				InnerSpace.Echo("    starts it, without additional clicks");
				InnerSpace.Echo(" Instructions:");
				InnerSpace.Echo("    1) Place the .cs and .xml in Scripts\\AttachWindbg\\");
				InnerSpace.Echo("    2) Add the following to Pre-Startup for the game you wish to attach:");
				InnerSpace.Echo("        \"<Setting Name=\"AttachWindbg\">execute ${If[${LavishScript.Executable.Find[ExeFile.exe](exists)},run AttachWindbg exefile.exe]}</Setting>\"");
				InnerSpace.Echo("    3) Be sure to updat ethe executable name in the above command");
				InnerSpace.Echo(" ");
				InnerSpace.Echo("Error: Executable to attach to must be specified on the command line");
				return;
			}
			try
			{
				ProcessStartInfo startInfo = new ProcessStartInfo("C:\\Program Files (x86)\\Windows Kits\\8.0\\Debuggers\\x86\\windbg.exe", "-pb -loga d:\\windbg.log -p " + args[0]);
				System.Diagnostics.Process.Start(startInfo);
			}
			catch (Exception e)
			{
				ProcessStartInfo startInfo = new ProcessStartInfo("C:\\Program Files (x86)\\Debugging Tools for Windows (x86)\\windbg.exe", "-pb -loga d:\\windbg.log -p " + args[0]);
				System.Diagnostics.Process.Start(startInfo);
			}
		}
	}
}

