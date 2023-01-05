# cmake-nvim

https://user-images.githubusercontent.com/107340417/210671231-10f54ff1-a372-4957-8975-10a195fba2eb.mp4

Runs CMake tools from command-line and writes output to a new buffer.

# Configuration
1-) From ```init.lua```
Add following to your ```.config/init.lua``` file:
```lua
use "yunusey/cmake-nvim"
```
2-) From github
```bash
cd ~/.local/share/nvim/site/pack/packer/start/
git clone https://github.com/yunusey/cmake-nvim.git
```

# Using Commands
```
:EnterProject
```
The first command that should be used is the one above. It asks for ```source_dir```, ```build_dir```, and ```executable_name```.

```source_dir```: Where your main ```CMakeLists.txt``` is located.

```build_dir```: Your ```build/``` directory.

```executable_name```: Your executable's name (Project name).

---

```
:ConfigProject
```
Using given ```source_dir``` and ```build_dir```, executes the following:
```bash
cmake -S {source_dir} -B {build_dir}
```

---

```
:BuildProject
```
Using given ```build_dir```, executes the following:
```bash
cmake --build {build_dir}
```

---

```
:RunProject
```
Using given ```executable_name```, executes the following:
```bash
{executable_name}
```

---

```
:ConfigBuildProject
```
First, configures the project. If exits without errors, builds the project.

---


```
:ConfigBuildProject
```
First, builds the project. If exits without errors, runs the project.

---

# Customization
The plugin files are located at ```.local/share/nvim/site/pack/packer/start/cmake-nvim/lua/```. Using ```cmake.lua```, you can customize your plugin. The first customization I'd suggest is ```configurations``` table in ```cmake.lua```. By default it's:
```lua
local configurations = {}
configurations["ShowConfig"] = true
configurations["ShowBuild"] = true
configurations["ShowRun"] = true
```
By changing the values of those keys, you can set whether they should split window when they exit.

```lua
configurations["UseTabs"] = true
```
By changing it to false, you can have the buffer splitted. 

# Quitting
My suggestion would be to quit using ```<leader>q``` which is mapped, because it deletes the buffer. If you don't delete the buffer, it will continue to use the same buffer. If you don't like it to happen, you can create an issue. I can add a configuration for it. 

PS: To use the same buffer has a lot of profits. The most important one is to know where you should look at. I, for example, use it in new-tab. I find it more comfortable. Whenever I get to a certain tab, I know that my CMake-Build output will be there.

# Errors
If you encounter with an error, please create an issue. By doing that so, you'll be helping me to improve project.

# Contribution
If you'd like to improve the cmake-nvim, I'd very much appreciate it. Please feel free to ask questions. Also, please consider answering issues and errors if you have knowledge on that.
