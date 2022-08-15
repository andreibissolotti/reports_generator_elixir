defmodule GenReportTest do
  use ExUnit.Case

  alias GenReport
  alias GenReport.Support.ReportFixture

  @file_name "gen_report.csv"
  @file_names_list ["part_1.csv", "part_2.csv", "part_3.csv"]

  describe "build/1" do
    test "When passing file name return a report" do
      response = GenReport.build(@file_name)

      assert response == ReportFixture.build()
    end

    test "When no filename was given, returns an error" do
      response = GenReport.build()

      assert response == {:error, "Insira o nome de um arquivo"}
    end
  end

  describe "build_from_many/1" do
    test "When passing filenames list return a report" do
      response = GenReport.build_from_many(@file_names_list)

      assert response == ReportFixture.build()
    end

    test "When no filenames list was given, returns an error" do
      response = GenReport.build_from_many()

      assert response == {:error, "Insira uma lista com nome de arquivos"}
    end
  end
end
