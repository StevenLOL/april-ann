dofile("binding/formiga.lua")
formiga.build_dir = "build_release_no_omp"

local packages = dofile "profile_build_scripts/package_list.lua"
table.insert(packages, "rlcompleter") -- AUTOCOMPLETION => needs READLINE

luapkg{
  program_name = "april-ann",
  verbosity_level = 0,  -- 0 => NONE, 1 => ONLY TARGETS, 2 => ALL
  packages = packages,
  version_flags = dofile "profile_build_scripts/VERSION.lua",
  disclaimer_strings = dofile "profile_build_scripts/DISCLAIMER.lua",
  global_flags = {
    debug="no",
    use_lstrip = "yes",
    use_readline="yes",
    optimization = "yes",
    platform = "unix",
    extra_flags={
      "-march=native",
      "-msse",
      "-DNDEBUG",
      "-DNO_OMP",
      "-fPIC",
    },
    extra_libs={
      "-fPIC",
      "-lpthread",
      "-lblas",
      "-lcblas",
      "-latlas",
      "-fopenmp",
      "-rdynamic",
      "-llapack_atlas",
      "-llapacke",
    },
    shared_extra_libs={
      "-shared",
      "-llua5.2",
    },
  },
  
  main_package = package{
    name = "main_package",
    default_target = "build",
    target{
      name = "init",
      mkdir{ dir = "bin" },
      mkdir{ dir = "build" },
      mkdir{ dir = "include" },
    },
    target{
      name = "provide",
      depends = "init",
      copy{ file = formiga.os.compose_dir(formiga.os.cwd,"lua","include","*.h"), dest_dir = "include" }
    },
    target{ name = "clean_all",
      exec{ command = [[find . -name "*~" -exec rm {} ';']] },
      delete{ dir = "bin" },
      delete{ dir = "build" },
      delete{ dir = "build_doc" },
      delete{ dir = "doxygen_doc" },
    },
    target{ name = "clean",
      delete{ dir = "bin" },
      delete{ dir = "build" },
      delete{ dir = "build_doc" },
    },
    target{ name = "document_clean",
      delete{ dir = "build_doc" },
      delete{ dir = "doxygen_doc" },
    },
    target{
      name = "build",
      depends = "provide",
      object{ 
	file = formiga.os.compose_dir("binding","c_src","*.cc"),
	include_dirs = "include",
	dest_dir = formiga.global_properties.build_dir,
      },
      link_main_program{},
      create_static_library{},
      copy_header_files{},
      dot_graph{
	file_name = "dep_graph.dot"
      },
      use_timestamp = true,
    },
    target{
      name = "test",
      depends = "build",
    },
    target{ name = "document",
      echo{"this is documentation"},
      main_documentation{
	dev_documentation = {
	  main_documentation_file = formiga.os.compose_dir("docs","april_dev.dox"),
	  doxygen_options = {
	    GENERATE_LATEX  = 'NO',
	  },
	},
	user_documentation = {
	  main_documentation_file = formiga.os.compose_dir("docs","april_user_ref.dox"),
	  doxygen_options = {
	    GENERATE_LATEX = 'NO',
	  },
	}
      },
    },
  },
}

if arg[2] == nil then
  arg[2] = "."
end

if arg[1] ~= "document" and arg[1] ~= "test" then
  formiga.os.execute("mkdir -p "..formiga.os.compose_dir(arg[2], "bin"))
  formiga.os.execute("mkdir -p "..formiga.os.compose_dir(arg[2], "lib"))
  formiga.os.execute("mkdir -p "..formiga.os.compose_dir(arg[2], "include"))
  formiga.os.execute("cp -f "..formiga.os.compose_dir(formiga.build_dir,"bin",formiga.program_name)
		       .." "..formiga.os.compose_dir(arg[2], "bin", formiga.program_name))
  formiga.os.execute("cp -R "..formiga.os.compose_dir(formiga.build_dir,"lib")
		       .." "..arg[2])
  formiga.os.execute("cp -R "..formiga.os.compose_dir(formiga.build_dir,"include","april-ann")
		       .." "..formiga.os.compose_dir(arg[2], "include"))

end
