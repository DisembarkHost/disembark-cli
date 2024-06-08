<?php
$phar = new Phar('disembark.phar');
$phar->buildFromDirectory(__DIR__);
$stub = "#!/usr/bin/env php \n";
$stub .= $phar->createDefaultStub('disembark');
$phar->setStub($stub);