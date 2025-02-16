using Oracle.ManagedDataAccess.Client;
using PodSproutFM.ExtraWindows;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;

namespace PodSproutFM.UserControls
{
    /// <summary>
    /// Логика взаимодействия для NarratorUC.xaml
    /// </summary>
    public partial class NarratorUC : UserControl
    {
        OracleConnection con = new OracleConnection();
        String connectionString = "DATA SOURCE=//localhost:1521/PodSproutPDB;PERSIST SECURITY INFO=True;USER ID=SYS;PASSWORD=jokimi;DBA PRIVILEGE=SYSDBA";
        Int16 id;
        string name;

        private void CheckRole()
        {
            if (DataWorker.CurrentUserRole == "ADMIN")
            {
                adminButtons.Visibility = Visibility.Visible;
                return;
            }
            else return;
        }

        public NarratorUC()
        {
            InitializeComponent();
            CheckRole();
            con.ConnectionString = connectionString;
        }
        public NarratorUC(Int16 narrId, string narrName)
        {
            InitializeComponent();
            CheckRole();
            con.ConnectionString = connectionString;
            this.id = narrId;
            this.name = narrName;
            blockNarratorName.Text = narrName;
        }

        private void EditNarrator_Click(object sender, RoutedEventArgs e)
        {
            UpdateNarrator updateWin = new UpdateNarrator(this.name);
            updateWin.Show();
            Application.Current.Windows[0].Hide();
        }

        private void ShowPodcasts_Click(object sender, RoutedEventArgs e)
        {
            ShowPodcastsByNarrator show = new ShowPodcastsByNarrator(name);
            show.Show();
            Application.Current.Windows[0].Hide();
        }

        private void DeleteNarrator_Click(object sender, RoutedEventArgs e)
        {
            MessageBoxResult messageBoxResult = System.Windows.MessageBox.Show("Вы уверены, что хотите удалить этого диктора?", "Подтверждение удаления", System.Windows.MessageBoxButton.YesNo);
            if (messageBoxResult == MessageBoxResult.Yes)
            {
                con.Open();
                OracleCommand cmd = con.CreateCommand();
                cmd.CommandText = "SYS.DELETENARRATOR";
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add("PID", OracleDbType.Int16, 10).Value = id;
                try
                {
                    cmd.ExecuteNonQuery();
                    MessageBox.Show("Диктор успешно удален!");
                    this.Visibility = Visibility.Collapsed;
                }
                catch (OracleException exc)
                {
                    MessageBox.Show("Ошибка удаления диктора: " + exc.Message);
                }
                con.Close();
            }
        }
    }
}