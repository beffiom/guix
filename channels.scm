(cons* (channel
        (name 'nonguix)
        (url "https://gitlab.com/nonguix/nonguix")
        (branch "master")
        (introduction
         (make-channel-introduction
          "897c1a470da759236cc11798f4e0a5f7d4d59fbc"
          (openpgp-fingerprint
           "2A39 3FFF 68F4 EF7A 3D29  12AF 6F51 20A0 22FB B2D5"))))
        (channel
         (name 'home-service-dwl-guile)
         (url "https://github.com/engstrand-config/home-service-dwl-guile")
         (branch "main")
         (introduction
          (make-channel-introduction
           "314453a87634d67e914cfdf51d357638902dd9fe"
           (openpgp-fingerprint
            "C9BE B8A0 4458 FDDF 1268 1B39 029D 8EB7 7E18 D68C"))))
       %default-channels)

