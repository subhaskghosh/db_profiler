package ai.salesdna.parser;

import org.apache.commons.cli.*;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.Map;

public class Driver {
    public static void main(String[] args) throws Exception {
        Options options = new Options();

        Option inputOption = new Option("i", "input", true, "input file path");
        inputOption.setRequired(true);
        options.addOption(inputOption);

        Option outputOption = new Option("o", "output", true, "output file");
        outputOption.setRequired(true);
        options.addOption(outputOption);

        CommandLineParser cliParser = new DefaultParser();
        HelpFormatter formatter = new HelpFormatter();
        CommandLine cmd = null;

        try {
            cmd = cliParser.parse(options, args);
        } catch (ParseException e) {
            System.out.println(e.getMessage());
            formatter.printHelp("TD SQL Parser:", options);
            System.exit(1);
        }

        String inputFilePath = cmd.getOptionValue("input");
        String outputFilePath = cmd.getOptionValue("output");

        PostgreSQLToJsonGenerator jg = new PostgreSQLToJsonGenerator(inputFilePath);
        Map<String, Object> parseMap = jg.getJson();
        String outputJson = jg.toJson(parseMap);


        try {
            PrintWriter fos = new PrintWriter(outputFilePath);
            fos.println(outputJson);
            System.out.println(outputJson);
            fos.close();
        } catch (IOException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
    }

}
