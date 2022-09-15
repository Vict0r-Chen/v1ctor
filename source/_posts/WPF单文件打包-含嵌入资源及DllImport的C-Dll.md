---
title: WPF单文件打包分享(含嵌入资源及DllImport的C++ Dll)
tags:
  - WPF
  - Fody
  - 打包
categories:
  - WPF
abbrlink: 1405049717
date: 2022-09-15 22:10:41
---

一般而言，除单项目且无其它引用的WPF应用（控制台、Winform等其它应用也是如此）（对了，还要除掉dotNET 6的单文件发布🤣），在构建后，运行所需的文件不止一个，通常还会带有几个DLL或其它的文件（如各种媒体文件：mp3、mp4、png等），此时分发起来显然不够方便。然后又在某些情况下我们可能不希望制作安装包，此时[`Costura.Fody`](https://github.com/Fody/Costura)就可以派上用场了。

<!--more-->

## Costura.Fody

据此项目的[Github](https://github.com/Fody/Home/blob/master/pages/licensing-patron-faq.md#why-not-use-a-modified-mit-license)页所述，虽然这个项目使用的是最宽松的`MIT`开源协议，但其实这居然是个收费项目😂😂😂，这与此前流行的“诚信商店”真是有着异曲同工之妙！

所以...如果我使用了这个项目并且没有贡献至少3美刀就变成失信人了？🤔

对了，等咱有钱了再贡献嘛😁😁

话说回来，`Costura.Fody`非常强大，大部分情况下只需要安装这个包就行了。

所以全部的操作就是：在`nuget`安装`Costura.Fody`到入口项目，非常优雅！

如下图的项目结构，我在`SingleFilePackageTest`项目中引用了项目`SomeClassLibrary`，在安装了`Costura.Fody`后，在生成文件夹单独拷贝`SingleFilePackageTest.exe`即可运行。

{% asset_img 1.png %}

## 关于项目中其它资源

将对应资源的`生成操作`改为`Resource`（注意：**不是**`内容`或`嵌入的资源`），

然后我们就可以使用如下代码将其从项目资源中提取出来：

``` csharp
/// <summary>
/// 从“资源”中加载文件的byte数组
/// </summary>
/// <param name="pathInApplication">资源路径</param>
/// <param name="byCurrentAssembly">资源是否在当前项目中</param>
/// <returns>资源文件byte数组</returns>
public static byte[] LoadFileFromResource(string pathInApplication, bool byCurrentAssembly = true)
{
    var assembly = byCurrentAssembly ? Assembly.GetCallingAssembly() : Assembly.GetEntryAssembly();
    if (pathInApplication[0] == '/')
    {
        pathInApplication = pathInApplication.Substring(1);
    }
    var resFilestream = Application.GetResourceStream(new Uri(@"pack://application:,,,/" + assembly.GetName().Name + ";component/" + pathInApplication, UriKind.Absolute));
    var ms = new MemoryStream();
    resFilestream.Stream.CopyTo(ms);
    var bytes = ms.ToArray();
    return bytes;
}

//假设项目下有个`Assets`文件夹，里面有个文件`Test.mp3`，那么调用方式如下：
var resourceBytes = LoadFileFromResource("/Assets/Test.mp3", true);
Debug.WriteLine($"文件长度：{resourceBytes.Length}");
```

接下来将其保存到临时目录就可以想咋玩就咋玩啦！

### 对于需要通过DllImport调用的DLL

如果项目中包含需要使用`DllImport`调用的dll时，首先通过上述方式将DLL保存到临时目录，再将临时目录追加到当前进程的`PATH`环境变量中，然后使用`DllImport`才可以正确调用到dll。

**上代码：**

在使用`DllImport`前先调用下面的代码：

``` csharp
EmbeddedDllClass.ExtractEmbeddedDlls("MyLib.dll", LoadFileFromResource("/MyLib.dll", true));
EmbeddedDllClass.LoadDll("MyLib.dll");
```


``` csharp EmbeddedDllClass.cs
public class EmbeddedDllClass
{
    private static string tempFolder = "";
    public static void ExtractEmbeddedDlls(string dllName, byte[] resourceBytes)
    {
        Assembly assem = Assembly.GetExecutingAssembly();
        string[] names = assem.GetManifestResourceNames();
        AssemblyName an = assem.GetName();

        tempFolder = String.Format("{0}.{1}.{2}", an.Name, an.ProcessorArchitecture, an.Version);

        string dirName = Path.Combine(Path.GetTempPath(), tempFolder);
        if (!Directory.Exists(dirName))
        {
            Directory.CreateDirectory(dirName);
        }

        string path = Environment.GetEnvironmentVariable("PATH");
        string[] pathPieces = path.Split(';');
        bool found = false;
        foreach (string pathPiece in pathPieces)
        {
            if (pathPiece == dirName)
            {
                found = true;
                break;
            }
        }
        if (!found)
        {
            Environment.SetEnvironmentVariable("PATH", dirName + ";" + path);
        }

        string dllPath = Path.Combine(dirName, dllName);
        bool rewrite = true;
        if (File.Exists(dllPath))
        {
            byte[] existing = File.ReadAllBytes(dllPath);
            if (resourceBytes.SequenceEqual(existing))
            {
                rewrite = false;
            }
        }
        if (rewrite)
        {
            File.WriteAllBytes(dllPath, resourceBytes);
        }
    }

    [DllImport("kernel32", SetLastError = true, CharSet = CharSet.Unicode)]
    static extern IntPtr LoadLibrary(string lpFileName);

    static public void LoadDll(string dllName)
    {
        if (tempFolder == "")
        {
            throw new Exception("Please call ExtractEmbeddedDlls before LoadDll");
        }
        IntPtr h = LoadLibrary(dllName);
        if (h == IntPtr.Zero)
        {
            Exception e = new Win32Exception();
            throw new DllNotFoundException("Unable to load library: " + dllName + " from " + tempFolder, e);
        }
    }
}
```

本文部分代码来自[StackOverflow@Mark Lakata](https://stackoverflow.com/questions/666799/embedding-unmanaged-dll-into-a-managed-c-sharp-dll/11038376#11038376)，感谢！