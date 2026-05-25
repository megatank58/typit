{ lib, beamPackages, overrides ? (x: y: {}) }:

let
  buildRebar3 = lib.makeOverridable beamPackages.buildRebar3;
  buildMix = lib.makeOverridable beamPackages.buildMix;
  buildErlangMk = lib.makeOverridable beamPackages.buildErlangMk;

  self = packages // (overrides self packages);

  packages = with beamPackages; with self; {
    castle = buildMix rec {
      name = "castle";
      version = "0.3.1";

      src = fetchHex {
        pkg = "castle";
        version = "${version}";
        sha256 = "3ee9ca04b069280ab4197fe753562958729c83b3aa08125255116a989e133835";
      };

      beamDeps = [ forecastle ];
    };

    castore = buildMix rec {
      name = "castore";
      version = "1.0.16";

      src = fetchHex {
        pkg = "castore";
        version = "${version}";
        sha256 = "33689203a0eaaf02fcd0e86eadfbcf1bd636100455350592e7e2628564022aaf";
      };

      beamDeps = [];
    };

    certifi = buildRebar3 rec {
      name = "certifi";
      version = "2.15.0";

      src = fetchHex {
        pkg = "certifi";
        version = "${version}";
        sha256 = "b147ed22ce71d72eafdad94f055165c1c182f61a2ff49df28bcc71d1d5b94a60";
      };

      beamDeps = [];
    };

    chacha20 = buildMix rec {
      name = "chacha20";
      version = "1.0.4";

      src = fetchHex {
        pkg = "chacha20";
        version = "${version}";
        sha256 = "2027f5d321ae9903f1f0da7f51b0635ad6b8819bc7fe397837930a2011bc2349";
      };

      beamDeps = [];
    };

    cowlib = buildRebar3 rec {
      name = "cowlib";
      version = "2.16.0";

      src = fetchHex {
        pkg = "cowlib";
        version = "${version}";
        sha256 = "7f478d80d66b747344f0ea7708c187645cfcc08b11aa424632f78e25bf05db51";
      };

      beamDeps = [];
    };

    curve25519 = buildMix rec {
      name = "curve25519";
      version = "1.0.5";

      src = fetchHex {
        pkg = "curve25519";
        version = "${version}";
        sha256 = "0fba3ad55bf1154d4d5fc3ae5fb91b912b77b13f0def6ccb3a5d58168ff4192d";
      };

      beamDeps = [];
    };

    dotenv = buildMix rec {
      name = "dotenv";
      version = "3.1.0";

      src = fetchHex {
        pkg = "dotenv";
        version = "${version}";
        sha256 = "01bed84d21bedd8739aebad16489a3ce12d19c2d59af87377da65ebb361980d3";
      };

      beamDeps = [];
    };

    dotenvy = buildMix rec {
      name = "dotenvy";
      version = "1.0.1";

      src = fetchHex {
        pkg = "dotenvy";
        version = "${version}";
        sha256 = "0727f6c08636b6d6f935c5a0ccedfe0c05bc75e638683bd9fa0a26d7a9931d15";
      };

      beamDeps = [];
    };

    ed25519 = buildMix rec {
      name = "ed25519";
      version = "1.4.3";

      src = fetchHex {
        pkg = "ed25519";
        version = "${version}";
        sha256 = "37f9de6be4a0e67d56f1b69ec2b79d4d96fea78365f45f5d5d344c48cf81d487";
      };

      beamDeps = [];
    };

    equivalex = buildMix rec {
      name = "equivalex";
      version = "1.0.3";

      src = fetchHex {
        pkg = "equivalex";
        version = "${version}";
        sha256 = "46fa311adb855117d36e461b9c0ad2598f72110ad17ad73d7533c78020e045fc";
      };

      beamDeps = [];
    };

    forecastle = buildMix rec {
      name = "forecastle";
      version = "0.1.3";

      src = fetchHex {
        pkg = "forecastle";
        version = "${version}";
        sha256 = "07e1ffa79c56f3e0ead59f17c0163a747dafc210ca8f244a7e65a4bfa98dc96d";
      };

      beamDeps = [];
    };

    gun = buildRebar3 rec {
      name = "gun";
      version = "2.2.0";

      src = fetchHex {
        pkg = "gun";
        version = "${version}";
        sha256 = "76022700c64287feb4df93a1795cff6741b83fb37415c40c34c38d2a4645261a";
      };

      beamDeps = [ cowlib ];
    };

    jason = buildMix rec {
      name = "jason";
      version = "1.4.4";

      src = fetchHex {
        pkg = "jason";
        version = "${version}";
        sha256 = "c5eb0cab91f094599f94d55bc63409236a8ec69a21a67814529e8d5f6cc90b3b";
      };

      beamDeps = [];
    };

    kcl = buildMix rec {
      name = "kcl";
      version = "1.4.4";

      src = fetchHex {
        pkg = "kcl";
        version = "${version}";
        sha256 = "d156c708e8c3cadf204e21cac7f239795917614660b205c731f385c8098c39ae";
      };

      beamDeps = [ curve25519 ed25519 poly1305 salsa20 ];
    };

    mime = buildMix rec {
      name = "mime";
      version = "2.0.7";

      src = fetchHex {
        pkg = "mime";
        version = "${version}";
        sha256 = "6171188e399ee16023ffc5b76ce445eb6d9672e2e241d2df6050f3c771e80ccd";
      };

      beamDeps = [];
    };

    nostrum = buildMix rec {
      name = "nostrum";
      version = "0.10.4";

      src = fetchHex {
        pkg = "nostrum";
        version = "${version}";
        sha256 = "fcc2642bf5b09792865ec2c26c1a11c6aa5432bc623a65dd81141e1eab9f1b99";
      };

      beamDeps = [ castle certifi gun jason mime ];
    };

    poly1305 = buildMix rec {
      name = "poly1305";
      version = "1.0.4";

      src = fetchHex {
        pkg = "poly1305";
        version = "${version}";
        sha256 = "e14e684661a5195e149b3139db4a1693579d4659d65bba115a307529c47dbc3b";
      };

      beamDeps = [ chacha20 equivalex ];
    };

    rambo = buildMix rec {
      name = "rambo";
      version = "0.3.4";

      src = fetchHex {
        pkg = "rambo";
        version = "${version}";
        sha256 = "0cc54ed089fbbc84b65f4b8a774224ebfe60e5c80186fafc7910b3e379ad58f1";
      };

      beamDeps = [];
    };

    rustler = buildMix rec {
      name = "rustler";
      version = "0.37.1";

      src = fetchHex {
        pkg = "rustler";
        version = "${version}";
        sha256 = "24547e9b8640cf00e6a2071acb710f3e12ce0346692e45098d84d45cdb54fd79";
      };

      beamDeps = [ jason ];
    };

    rustler_precompiled = buildMix rec {
      name = "rustler_precompiled";
      version = "0.8.3";

      src = fetchHex {
        pkg = "rustler_precompiled";
        version = "${version}";
        sha256 = "c23f5f33cb6608542de4d04faf0f0291458c352a4648e4d28d17ee1098cddcc4";
      };

      beamDeps = [ castore rustler ];
    };

    salchicha = buildMix rec {
      name = "salchicha";
      version = "0.5.0";

      src = fetchHex {
        pkg = "salchicha";
        version = "${version}";
        sha256 = "b3e0575cd5a01672d9cefc4ec50bd56662a4d970e2ae39d8de6cf82f09012fc8";
      };

      beamDeps = [];
    };

    salsa20 = buildMix rec {
      name = "salsa20";
      version = "1.0.4";

      src = fetchHex {
        pkg = "salsa20";
        version = "${version}";
        sha256 = "745ddcd8cfa563ddb0fd61e7ce48d5146279a2cf7834e1da8441b369fdc58ac6";
      };

      beamDeps = [];
    };

    sourceror = buildMix rec {
      name = "sourceror";
      version = "1.10.0";

      src = fetchHex {
        pkg = "sourceror";
        version = "${version}";
        sha256 = "29dbdfc92e04569c9d8e6efdc422fc1d815f4bd0055dc7c51b8800fb75c4b3f1";
      };

      beamDeps = [];
    };
  };
in self

