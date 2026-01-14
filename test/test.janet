(def module-env (dofile "vtt2txt.janet"))
(def vtt->txt (get (get module-env 'vtt->txt) :value))

(defn assert-equal [expected actual label]
  (when (not= expected actual)
    (printf "FAIL: %s\nExpected: %q\nActual: %q\n" label expected actual)
    (os/exit 1)))

(defn run-tests []
  (def sample-basic
    "WEBVTT\n\n1\n00:00:00.000 --> 00:00:01.000\nHello World\n\n2\n00:00:01.000 --> 00:00:02.000\nSecond line\n")
  (assert-equal "Hello World\n\nSecond line"
                (vtt->txt sample-basic)
                "basic cues are kept and separated by blank line")

  (def sample-cleanup
    "\ufeffWEBVTT\r\n\r\nNOTE ignored note\r\nline\r\n\r\nSTYLE\nvtt { }\r\n\r\nREGION\ninfo\r\n\r\n42\r\n00:00:02.000 --> 00:00:03.000\r\nFirst\r\n\r\n43\r\n00:00:03.500 --> 00:00:04.000\r\nSecond\r\n\r\n")
  (assert-equal "First\n\nSecond"
                (vtt->txt sample-cleanup)
                "BOM, CRLF, notes, styles, regions, cue ids, and timestamps are removed")

  (print "All tests passed."))

(run-tests)
