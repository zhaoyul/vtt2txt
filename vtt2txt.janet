#! /usr/bin/env janet

(defn prefix? [s prefix]
  (let [idx (string/find prefix s)]
    (and idx (= 0 idx))))

(def script-pattern ~"[^/\\\\]+%.janet$")

(defn numeric-line? [s]
  (and (> (length s) 0)
       (all (fn [b] (and (>= b 48) (<= b 57)))
            (string/bytes s))))

(defn read-file [path]
  (try
    (slurp path)
    ([err]
     (printf "Failed to read '%s': %v\n" path err)
     (os/exit 1))))

(defn write-file [path data]
  (try
    (spit path data)
    ([err]
     (printf "Failed to write '%s': %v\n" path err)
     (os/exit 1))))

(defn push-text [out line]
  (if (= "" line)
    (when (and (> (length out) 0) (not= "" (last out)))
      (array/push out ""))
    (array/push out line)))

(defn clean-lines [content]
  (var normalized (string/replace "\r\n" "\n" content))
  (set normalized (string/replace "\ufeff" "" normalized))
  (var output @[])
  (var skip-block false)
  (each line (string/split "\n" normalized)
    (def trimmed (string/trim line))
    (if skip-block
      (when (= "" trimmed) (set skip-block false))
      (cond
        (prefix? trimmed "WEBVTT") nil
        (prefix? trimmed "NOTE") (set skip-block true)
        (prefix? trimmed "STYLE") (set skip-block true)
        (prefix? trimmed "REGION") (set skip-block true)
        (string/find "-->" trimmed) nil
        # Skip numeric cue identifiers like "12"
        (numeric-line? trimmed) nil
        :else (push-text output trimmed))))
  (while (and (> (length output) 0) (= "" (last output)))
    (array/pop output))
  output)

(defn vtt->txt [content]
  (string/join (clean-lines content) "\n"))

(defn usage []
  (print "Usage: janet vtt2txt.janet <input.vtt> [output.txt]"))

# Normalize CLI arguments and strip script path (e.g. vtt2txt.janet) when present.
(defn cli-argv [args]
  (let [argv (if (> (length args) 0)
               args
                (or (dyn :args) []))]
    (if (and (> (length argv) 0)
             (peg/match script-pattern (first argv)))
      (tuple/slice argv 1)
      argv)))

(defn -main [& args]
  (let [argv (cli-argv args)
        argc (length argv)]
    (cond
      (or (= 0 argc) (> argc 2)) (do (usage) (os/exit 1))
      (= 1 argc) (print (vtt->txt (read-file (first argv))))
      :else (write-file (last argv) (vtt->txt (read-file (first argv)))))))

(defn main [& args]
  (apply -main args))

# Run entrypoint only when executed as a script, not when imported as a module.
(when (= (dyn :state) :script)
  (apply -main (or (dyn :args) [])))
