<?php
$phar = new Phar('disembark.phar');
$phar->startBuffering();

// 1. Add the main disembark script
// We add it by its file name, and also give it the same name inside the phar
$phar->addFile('disembark', 'disembark');

// 2. Add the entire vendor directory recursively
$vendorDir = __DIR__ . '/vendor';
$iterator = new RecursiveIteratorIterator(
    new RecursiveDirectoryIterator(
        $vendorDir,
        FilesystemIterator::SKIP_DOTS
    )
);

// Add all files from vendor, preserving their paths relative to the root
foreach ($iterator as $file) {
    if ($file->isDir()) {
        continue;
    }
    
    $path = $file->getRealPath();
    // Get the path relative to the project root (e.g., "vendor/rmccue/requests/src/Requests.php")
    $relativePath = substr($path, strlen(__DIR__) + 1);
    
    $phar->addFile($path, $relativePath);
}

// 3. Create the stub
$stub = "#!/usr/bin/env php \n";
$stub .= $phar->createDefaultStub('disembark'); // This still points to 'disembark' at the phar's root
$phar->setStub($stub);

$phar->stopBuffering();
echo "disembark.phar built successfully.\n";