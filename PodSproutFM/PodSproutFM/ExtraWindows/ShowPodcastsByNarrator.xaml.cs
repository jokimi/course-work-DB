using Oracle.ManagedDataAccess.Client;
using Oracle.ManagedDataAccess;
using PodSproutFM.UserControls;
using System;
using System.Data;
using System.Windows;
using Oracle.ManagedDataAccess.Types;

namespace PodSproutFM.ExtraWindows
{
    /// <summary>
    /// Логика взаимодействия для ShowPodcastsByNarrator.xaml
    /// </summary>
    public partial class ShowPodcastsByNarrator : Window
    {
        OracleConnection con = new OracleConnection();
        string connectionString = "DATA SOURCE=//localhost:1521/PodSproutPDB;PERSIST SECURITY INFO=True;USER ID=SYS;PASSWORD=jokimi;DBA PRIVILEGE=SYSDBA";
        string narratorVal;

        public ShowPodcastsByNarrator()
        {
            InitializeComponent();
            con.ConnectionString = connectionString;
        }

        public ShowPodcastsByNarrator(string narrator)
        {
            InitializeComponent();
            con.ConnectionString = connectionString;
            this.narratorVal = narrator;
            narratorName.Text = narrator;
        }

        public void LoadNPodcasts()
        {
            try
            {
                con.Open();
                using (OracleCommand cmd = con.CreateCommand())
                {
                    cmd.CommandText = "SYS.SEARCHPODCASTBYNARRATOR";
                    cmd.CommandType = CommandType.StoredProcedure;
                    string narrator = narratorVal.ToUpper();
                    if (string.IsNullOrEmpty(narrator))
                    {
                        MessageBox.Show("Имя диктора не может быть пустым.");
                        return;
                    }
                    cmd.Parameters.Add("PNARRATORNAME", OracleDbType.Varchar2, 30).Value = narrator;
                    OracleParameter cursorParam = new OracleParameter("oPodcastCursor", OracleDbType.RefCursor);
                    cursorParam.Direction = ParameterDirection.Output;
                    cmd.Parameters.Add(cursorParam);
                    cmd.ExecuteNonQuery();
                    using (OracleDataReader reader = cmd.ExecuteReader())
                    {
                        podcastList.Children.Clear();
                        int count = 0;
                        while (reader.Read())
                        {
                            count++;
                            int podcastId = reader.IsDBNull(0) ? 0 : reader.GetInt32(0);
                            string podcastName = reader.IsDBNull(1) ? "Неизвестно" : reader.GetString(3);
                            string topicName = reader.IsDBNull(2) ? "Неизвестно" : reader.GetString(2);
                            string narratorName = reader.IsDBNull(3) ? "Неизвестно" : reader.GetString(1);
                            int topicYear = reader.IsDBNull(4) ? 0 : reader.GetInt16(4);
                            PodcastUC podcast = new PodcastUC(podcastId, podcastName, topicName, narratorName, (short)topicYear);
                            podcastList.Children.Add(podcast);
                        }
                        if (count == 0)
                        {
                            MessageBox.Show("Нет подкастов для отображения.");
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Ошибка при загрузке подкастов: {ex.Message}\n{ex.StackTrace}");
            }
            finally
            {
                con.Close();
            }
        }

        private void CloseBtn_Click(object sender, RoutedEventArgs e)
        {
            this.Close();
            Application.Current.Windows[0].Show();
        }

        private void Window_Loaded(object sender, RoutedEventArgs e)
        {
            LoadNPodcasts();
        }

        private void BtnClose_Click(object sender, RoutedEventArgs e)
        {
            this.Close();
            Application.Current.Windows[0].Show();
        }

        private void BtnMinimize_Click(object sender, RoutedEventArgs e)
        {
            this.WindowState = WindowState.Minimized;
        }
    }
}