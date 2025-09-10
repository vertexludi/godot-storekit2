# Godot iOS plugin template

Use this project as a base for custom iOS plugins for Godot.

## Building the template

Make sure you fetch the submodules, since that includes the Godot source which is necessary for building.

```sh
$ git submodule update --init
```

Generate the headers from Godot by starting a build. You can use the provided script:

```sh
$ ./scripts/generate_headers.sh
```

Open the project on Xcode and build from there.

There's also a script that builds both debug and release versions of the plugin and pack it in a Zip file for distribution:

```sh
$ ./scripts/make_release.sh
```

With the resulting folder under `bin`, you can put it in the Godot project under the `ios/plugins` folder.

## Updating the template

Change the `iOSPluginTemplate` string with your plugin name in all files. Also rename the folders.

Adjust the development team in the build settings of the project on Xcode.

Using Xcode you can add new header and source files to the project. Everything added will be built automatically.

>[!NOTE]
>This template targets Godot version 4.4.1. It won't work with different versions.
>If want to target a different one, go into the `godot` folder and update the submodule to a different release.
>
>E.g. `git switch -d 4.5-stable`
