## Patching your ROM (Windows)
1. Place your rom in the rom folder and make sure it's named nhl94.bin 
2. Run the build.bat file from the command prompt or terminal.
3. Batch file should generate files in the `output` folder.

## Output
    output/
    ├── Build.log             # Log file containing any errors during compilation.
    └── nhl94_patched.bin     # Patched ROM file if the build was successful without errors.
	
## Notes
1.  Patch.asm contains the code that will get patched into the existing NHL94.bin file.
2.  The new code gets inserted in the ROM at address $0FFB10. 
    If you have a custom ROM and want to change this location, change the NewCodeAddr value in the patch.asm file.