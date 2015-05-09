# Versioning Policy

* CLI interface: Adding options is a non-breaking change, and would warrant an update of the minor version. Removing options is a breaking change and requires a major version update (we did this going to reek 2). Adding a report format probably also warrents a minor version upgrade.
* API: We haven't really defined a 'public' API for using Reek programmatically, and we've only just started testing it. So, this is basically a blank slate at the moment. We will work on this as a part of the reek 3 release.
* List of detected smells: Adding a smell warrants a minor release, removing a smell is a breaking change. This makes sense if you consider that the CLI allows running a single smell detector.
* Consistency of detected smells: This is very hard to guarantee. If we fix a bug in one of the detectors, some fragrant code may become smelly, or vice versa. Right now we don't bother with this.
* Smell configuration: The detectors are quite tolerant regarding configuration options that they don't recognize, so we regard any change here as only requiring a minor release.
